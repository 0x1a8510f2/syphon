import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syphon/global/libs/matrix/index.dart';
import 'package:syphon/global/notifications.dart';
import 'package:syphon/global/print.dart';
import 'package:syphon/global/values.dart';
import 'package:syphon/store/rooms/room/model.dart';
import 'package:syphon/store/settings/notification-settings/model.dart';
import 'package:syphon/store/sync/background/model.dart';
import 'package:syphon/store/sync/background/parsers.dart';
import 'package:syphon/store/sync/background/requests.dart';
import 'package:syphon/store/sync/background/storage.dart';
import 'package:syphon/store/sync/parsers.dart';
import 'package:syphon/store/user/model.dart';

/// Background Sync Service (Android Only)
/// static class for managing service through app lifecycle
class BackgroundSync {
  static const service_id = 255;
  static const serviceTimeout = 55; // seconds

  // background data identifiers
  static const protocolKey = 'protocol';
  static const lastSinceKey = 'lastSince';
  static const roomNamesKey = 'roomNamesKey';
  static const currentUserKey = 'currentUserKey';
  static const notificationSettingsKey = 'notificationSettings';
  static const notificationsUncheckedKey = 'notificationsUnchecked';

  static Future<bool> init() async {
    try {
      return await AndroidAlarmManager.initialize();
    } catch (error) {
      printError('[BackgroundSync.init] $error');
      return false;
    }
  }

  static Future start({
    String? protocol,
    String? lastSince,
    User? currentUser,
    Map<String, String?>? roomNames,
    NotificationSettings? settings,
  }) async {
    // android only background sync
    if (!Platform.isAndroid) return;

    log.info('[BackgroundSync] starting');

    final secureStorage = FlutterSecureStorage();

    // only write here if one does not exist
    if (!await secureStorage.containsKey(key: BackgroundSync.lastSinceKey)) {
      await secureStorage.write(key: BackgroundSync.lastSinceKey, value: lastSince);
    }

    await Future.wait([
      secureStorage.write(key: BackgroundSync.protocolKey, value: protocol),
      secureStorage.write(key: BackgroundSync.roomNamesKey, value: jsonEncode(roomNames)),
      secureStorage.write(key: BackgroundSync.notificationSettingsKey, value: jsonEncode(settings)),
      secureStorage.write(key: BackgroundSync.currentUserKey, value: jsonEncode(currentUser)),
    ]);

    await AndroidAlarmManager.periodic(
      Duration(seconds: serviceTimeout),
      service_id,
      notificationJob,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );

    // immediately begin checking for notifications
    compute(notificationJobThreaded, {});
  }

  static Future stop() async {
    try {
      await AndroidAlarmManager.cancel(service_id);
    } catch (error) {
      log.error('[BackgroundSync] $error');
    }
  }
}

///
/// Notification Job Threaded (Android Only)
///
/// Same as below, but works in compute / isolates outside alarm_services
///
/// TODO: not working off main thread - due to secure storage and flutter widget binding
Future notificationJobThreaded(Map params) async {
  return notificationJob();
}

///
/// Notification Job (Android Only)
///
/// Fetches data from matrix in background and displays
/// notifications without needing google play services
///
/// NOTE: https://github.com/flutter/flutter/issues/32164
///
Future notificationJob() async {
  try {
    User currentUser;
    String? protocol;
    String? lastSince;

    try {
      final secureStorage = FlutterSecureStorage();
      protocol = await secureStorage.read(key: BackgroundSync.protocolKey);
      lastSince = await secureStorage.read(key: BackgroundSync.lastSinceKey);

      final _userString = await secureStorage.read(key: BackgroundSync.currentUserKey);
      currentUser = User.fromJson(jsonDecode(_userString ?? '{}'));
    } catch (error) {
      return log.threaded('[notificationJob] decode error $error');
    }

    final Map<String, String> roomNames = await loadRoomNames();

    // Init notifiations for background service and new messages/events
    final pluginInstance = await initNotifications(
      onSelectNotification: (String? payload) {
        log.threaded('[onSelectNotification] TESTING PAYLOAD INSIDE BACKGROUND THREAD $payload');
        return Future.value(true);
      },
    );

    if (pluginInstance == null) {
      throw '[notificationJob] failed to initialize plugin instance';
    }

    showBackgroundServiceNotification(
      notificationId: BackgroundSync.service_id,
      pluginInstance: pluginInstance,
    );

    final cutoff = DateTime.now().add(
      Duration(seconds: BackgroundSync.serviceTimeout),
    );

    while (DateTime.now().isBefore(cutoff)) {
      await Future.delayed(Duration(seconds: 2));

      // TODO: check for on the fly disabled notification services
      await backgroundSync(
        pluginInstance: pluginInstance,
        params: {
          'protocol': protocol,
          'userId': currentUser.userId,
          'homeserver': currentUser.homeserver,
          'accessToken': currentUser.accessToken,
          'lastSince': lastSince,
          'roomNames': roomNames,
        },
      );
    }
  } catch (error) {
    log.threaded('[notificationJob] $error');
  }
}

///
/// Background Sync (Android Only)
///
/// Fetches data from matrix in background and displays
/// notifications without needing google play services
///
Future backgroundSync({
  required Map params,
  required FlutterLocalNotificationsPlugin pluginInstance,
}) async {
  try {
    log.threaded('[backgroundSync] starting sync loop');

    final protocol = params['protocol'];
    final homeserver = params['homeserver'];
    final accessToken = params['accessToken'];
    final lastSince = params['lastSince'];
    final currentUserId = params['userId'];

    var roomNames = Map<String, String>.from(
      params['roomNames'] ?? {},
    );

    if (accessToken == null || lastSince == null) {
      return;
    }

    // Try to pull new lastSince if available
    final settings = await loadNotificationSettings();
    final currentLastSince = await loadLastSince(fallback: lastSince);

    // Prevents further updates within background service if
    // disabled mid AlarmManager cycle
    if (!settings.enabled) {
      return;
    }

    ///
    /// Check last since and see if any new messages arrived in the payload
    /// do not save the lastSince to the store and
    /// the next foreground fetchSync will update the state
    ///
    final data = await MatrixApi.sync(
      protocol: protocol,
      homeserver: homeserver,
      accessToken: accessToken,
      since: currentLastSince,
      timeout: 10000,
    );

    // Parse sync response
    final nextLastSince = data['next_batch'];

    // Save new 'since' value for the next sync
    saveLastSince(lastSince: nextLastSince);

    // Filter each room through the parser
    final Map<String, dynamic> roomJson = data['rooms'] ?? {};

    if (roomJson.isEmpty) {
      return;
    }

    final Map<String, dynamic> joinedJson = roomJson['join'] ?? {};
    final Map<String, dynamic> invitesJson = roomJson['invite'] ?? {};

    final roomsJson = joinedJson..addAll(invitesJson);

    // Run all the rooms at once
    await Future.forEach(roomsJson.keys, (String roomId) async {
      final roomJson = roomsJson[roomId];

      // Don't parse room if there are no message events found
      final events = parseEvents(roomJson);

      if (events.messages.isEmpty) {
        return;
      }

      final details = parseDetails(roomJson);

      final room = Room(id: roomId).fromEvents(
        events: events,
        currentUser: User(userId: currentUserId),
        lastSince: lastSince,
        limited: details.limited,
        lastBatch: details.lastBatch,
        prevBatch: details.prevBatch,
      );

      final chatOptions = settings.notificationOptions;
      final hasOptions = chatOptions.containsKey(roomId);

      if (settings.toggleType == ToggleType.Disabled && !hasOptions) {
        return;
      }

      if (hasOptions) {
        final options = chatOptions[roomId]!;
        if (!options.enabled) {
          return;
        }

        if (options.muted) {
          final mutedTimeout = DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(options.muteTimestamp),
          );

          // future timeout still has not been met
          if (mutedTimeout.isNegative) {
            return;
          }
        }
      }

      // Make sure the room name exists in the cache
      if (!roomNames.containsKey(roomId) || roomNames[roomId] == Values.EMPTY_CHAT) {
        roomNames = await updateRoomNames(
          protocol: protocol,
          homeserver: homeserver,
          accessToken: accessToken,
          roomId: room.id.isEmpty ? roomId : room.id,
          roomNames: roomNames,
        );
      }

      final uncheckedMessages = await loadNotificationsUnchecked();

      final List<NotificationContent> notifications = [];

      ///
      /// Parse and generate notification content
      ///
      for (final message in events.messages) {
        final title = parseMessageTitle(
          room: room,
          message: message,
          roomNames: roomNames,
          currentUserId: currentUserId,
        );

        final body = parseMessageNotification(
          room: room,
          message: message,
          roomNames: roomNames,
          currentUserId: currentUserId,
        );

        if (body.isNotEmpty) {
          uncheckedMessages.addAll(
            {message.id ?? '0': body},
          );

          notifications.add(
            NotificationContent(
              title: title,
              body: body,
            ),
          );
        }
      }

      await saveNotificationsUnchecked(uncheckedMessages);

      ///
      /// Inbox Style Notifications Only
      ///
      if (settings.styleType == StyleType.Inbox) {
        var body = 'You have a new unread message';

        if (uncheckedMessages.keys.length > 1) {
          body = 'You have ${uncheckedMessages.keys.length} unread messages';
        }

        return showMessageNotification(
          body: body,
          title: 'New Messages',
          style: settings.styleType,
          pluginInstance: pluginInstance,
          uncheckedMessages: uncheckedMessages,
        );
      }

      ///
      /// All other Notifications styles
      ///
      await Future.forEach(notifications, (NotificationContent notification) async {
        await showMessageNotification(
          id: uncheckedMessages.isEmpty ? 0 : null,
          body: notification.body,
          title: notification.title,
          style: settings.styleType,
          pluginInstance: pluginInstance,
        );
      });
    });
  } catch (error) {
    log.threaded('[BackgroundSync] $error');
  }
}

///
/// Foreground Sync Test (TESTING ONLY)
///
/// Fetches data from matrix in background and displays
/// notifications without needing google play services
///
/// NOTE: https://github.com/flutter/flutter/issues/32164
///
Future notificationSyncTEST() async {
  try {
    // Init notifiations for background service and new messages/events
    final pluginInstance = await initNotifications(
      onSelectNotification: (String? payload) {
        log.threaded('[onSelectNotification] payload $payload');
        return Future.value(true);
      },
    );
    User currentUser;
    String? protocol;
    String? lastSince;

    try {
      final secureStorage = FlutterSecureStorage();
      protocol = await secureStorage.read(key: BackgroundSync.protocolKey);
      lastSince = await secureStorage.read(key: BackgroundSync.lastSinceKey);
      currentUser = User.fromJson(
        jsonDecode(await secureStorage.read(key: BackgroundSync.currentUserKey) ?? '{}'),
      );
    } catch (error) {
      return log.threaded('[notificationSyncTEST] $error');
    }

    final Map<String, String> roomNames = await loadRoomNames();

    await backgroundSync(
      pluginInstance: pluginInstance!,
      params: {
        'protocol': protocol,
        'userId': currentUser.userId,
        'homeserver': currentUser.homeserver,
        'accessToken': currentUser.accessToken,
        'lastSince': lastSince,
        'roomNames': roomNames,
      },
    );
  } catch (error) {
    log.threaded('[notificationSyncTEST] $error');
  }
}

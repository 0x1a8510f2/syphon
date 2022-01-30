import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:syphon/global/colours.dart';
import 'package:syphon/global/dimensions.dart';
import 'package:syphon/global/strings.dart';
import 'package:syphon/store/events/messages/model.dart';
import 'package:syphon/store/events/selectors.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/rooms/actions.dart';
import 'package:syphon/store/rooms/room/model.dart';
import 'package:syphon/store/rooms/selectors.dart';
import 'package:syphon/store/settings/chat-settings/actions.dart';
import 'package:syphon/store/settings/chat-settings/selectors.dart';
import 'package:syphon/store/settings/notification-settings/actions.dart';
import 'package:syphon/store/settings/notification-settings/model.dart';
import 'package:syphon/store/settings/notification-settings/options/types.dart';
import 'package:syphon/store/user/actions.dart';
import 'package:syphon/store/user/model.dart';
import 'package:syphon/store/user/selectors.dart';
import 'package:syphon/views/widgets/avatars/avatar.dart';
import 'package:syphon/views/widgets/dialogs/dialog-color-picker.dart';
import 'package:syphon/views/widgets/dialogs/dialog-confirm.dart';

class ChatCallArguments {
  final String? roomId;
  final String? title;

  ChatCallArguments({
    this.roomId,
    this.title,
  });
}

class ChatCallScreen extends StatefulWidget {
  const ChatCallScreen({Key? key}) : super(key: key);

  @override
  ChatCallState createState() => ChatCallState();
}

class ChatCallState extends State<ChatCallScreen> {
  ChatCallState() : super();

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: 0,
  );

  double headerOpacity = 1;
  double headerSize = 54;
  List<User>? usersList;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      final height = MediaQuery.of(context).size.height;
      const minOffset = 0;
      final maxOffset = height * 0.2;
      final offsetRatio = scrollController.offset / maxOffset;

      final isOpaque = scrollController.offset <= minOffset;
      final isTransparent = scrollController.offset > maxOffset;
      final isFading = !isOpaque && !isTransparent;

      if (isFading) {
        return setState(() {
          headerOpacity = 1 - offsetRatio;
        });
      }

      if (isTransparent) {
        return setState(() {
          headerOpacity = 0;
        });
      }

      return setState(() {
        headerOpacity = 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @protected
  onBlockUser({required BuildContext context, required _Props props}) async {
    final user = props.users.firstWhere(
          (user) => user!.userId != props.currentUser.userId,
    );
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => DialogConfirm(
        title: Strings.buttonBlockUser,
        content: Strings.confirmBlockUser(name: user?.displayName),
        onConfirm: () async {
          await props.onBlockUser(user);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @protected
  onShowColorPicker({
    required BuildContext context,
    required int originalColor,
    required Function onSelectColor,
  }) async =>
      showDialog(
        context: context,
        builder: (BuildContext context) => DialogColorPicker(
          title: 'Select Chat Color',
          currentColor: originalColor,
          onSelectColor: onSelectColor,
        ),
      );

  @protected
  onLeaveChat(_Props props) async {
    showDialog(
      context: context,
      builder: (dialogContext) => DialogConfirm(
        title: Strings.buttonLeaveChat.capitalize(),
        confirmText: Strings.buttonLeaveChat.capitalize(),
        confirmStyle: TextStyle(color: Colors.red),
        content: Strings.confirmLeaveRooms(rooms: [props.room]),
        onDismiss: () => Navigator.pop(dialogContext),
        onConfirm: () async {
          await props.onLeaveChat();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    // Confirm this is needed in chat details
    final titlePadding = Dimensions.listTitlePaddingDynamic(width: width);
    final contentPadding = Dimensions.listPaddingDynamic(width: width);

    final ChatCallArguments? arguments =
    ModalRoute.of(context)!.settings.arguments as ChatCallArguments?;

    final scaffordBackgroundColor = Theme.of(context).brightness == Brightness.light
        ? Color(Colours.greyLightest)
        : Theme.of(context).scaffoldBackgroundColor;

    return StoreConnector<AppState, _Props>(
      distinct: true,
      converter: (Store<AppState> store) => _Props.mapStateToProps(
        store,
        arguments?.roomId,
      ),
      builder: (context, props) {
        var notificationsEnabled = props.notificationSettings.toggleType == ToggleType.Enabled;

        if (props.notificationOptions != null) {
          notificationsEnabled = props.notificationOptions?.enabled ?? false;
        }

        return Scaffold(
          backgroundColor: scaffordBackgroundColor,
          body: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: height * 0.85,
                systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
                automaticallyImplyLeading: false,
                titleSpacing: 0.0,
                title: Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        arguments!.title!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                flexibleSpace: Hero(
                  tag: 'ChatAvatar',
                  child: Container(
                    padding: EdgeInsets.only(top: height * 0.075),
                    color: props.chatColorPrimary,
                    width: width,
                    child: OverflowBox(
                      minHeight: height * 0.5,
                      maxHeight: height * 0.85,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: headerOpacity,
                            child: Avatar(
                              size: height * 0.15,
                              uri: props.room.avatarUri,
                              alt: props.room.name,
                              background: props.chatColorPrimary,
                              rebuild: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}

class _Props extends Equatable {
  final Room room;
  final bool loading;
  final User currentUser;
  final List<User?> users;
  final Color chatColorPrimary;
  final List<Message> messages;
  final NotificationOptions? notificationOptions;
  final NotificationSettings notificationSettings;

  final Function onLeaveChat;
  final Function onBlockUser;
  final Function onSelectPrimaryColor;
  final Function onToggleDirectRoom;
  final Function onToggleRoomNotifications;

  const _Props({
    required this.room,
    required this.users,
    required this.loading,
    required this.messages,
    required this.currentUser,
    required this.onBlockUser,
    required this.onLeaveChat,
    required this.chatColorPrimary,
    required this.onSelectPrimaryColor,
    required this.onToggleDirectRoom,
    required this.notificationOptions,
    required this.notificationSettings,
    required this.onToggleRoomNotifications,
    // @required this.onViewEncryptionKeys,
  });

  @override
  List<Object> get props => [
    room,
    messages,
    chatColorPrimary,
    loading,
  ];

  static _Props mapStateToProps(Store<AppState> store, String? roomId) => _Props(
      loading: store.state.roomStore.loading,
      notificationSettings: store.state.settingsStore.notificationSettings,
      notificationOptions: store.state.settingsStore.notificationSettings.notificationOptions[roomId],
      room: selectRoom(id: roomId, state: store.state),
      users: roomUsers(store.state, roomId),
      currentUser: store.state.authStore.user,
      messages: roomMessages(store.state, roomId),
      onToggleRoomNotifications: () async {
        if (roomId != null) {
          await store.dispatch(toggleChatNotifications(roomId: roomId));
        }
      },
      onBlockUser: (User user) async {
        await store.dispatch(toggleBlockUser(user: user));
      },
      onLeaveChat: () async {
        await store.dispatch(leaveRoom(
          room: selectRoom(state: store.state, id: roomId),
        ));
      },
      chatColorPrimary: selectChatColor(store, roomId),
      onSelectPrimaryColor: (color) {
        store.dispatch(updateRoomPrimaryColor(
          roomId: roomId,
          color: color,
        ));
      },
      onToggleDirectRoom: () {
        final room = selectRoom(id: roomId, state: store.state);
        store.dispatch(toggleDirectRoom(room: room, enabled: !room.direct));
      });
}

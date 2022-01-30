import 'package:collection/collection.dart' show IterableExtension;
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:syphon/global/libs/matrix/index.dart';
import 'package:syphon/global/print.dart';
import 'package:syphon/store/events/actions.dart';
import 'package:syphon/store/events/messages/model.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/rooms/actions.dart';
import 'package:syphon/store/rooms/room/model.dart';

///
/// Send Call Invite
///
ThunkAction<AppState> sendCallInvite({
  Room? room,
  Message? message,
  String? emoji,
}) {
  return (Store<AppState> store) async {
    store.dispatch(UpdateRoom(id: room!.id, sending: true));
    try {
      await MatrixApi.sendReaction(
        trxId: DateTime.now().millisecond.toString(),
        accessToken: store.state.authStore.user.accessToken,
        homeserver: store.state.authStore.user.homeserver,
        roomId: room.id,
        messageId: message!.id,
        reaction: emoji,
      );

      return true;
    } catch (error) {
      printError('[sendReaction] $error');
      return false;
    } finally {
      store.dispatch(UpdateRoom(id: room.id, sending: false));
    }
  };
}

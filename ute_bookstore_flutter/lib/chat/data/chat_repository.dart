import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import 'package:cross_file/cross_file.dart';
import 'chat_api.dart';
import 'socket_service.dart';

class ChatRepository {
  final ChatApi _api;
  final SocketService _socket;
  SocketService get socket => _socket;

  // Biến lưu trữ callback hiện tại
  Function(Map<String, dynamic>)? _onMessageReceived;
  Function(Map<String, dynamic>)? _onReactionReceived;

  ChatRepository(this._api, this._socket);

  Future<List<ChatThread>> fetchChatThreads() async {
    final List data = await _api.getChatThreads();
    return data.map((e) => ChatThread.fromMap(e)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(String username) async {
    final List data = await _api.getChatHistory(username);
    return data.map((e) => ChatMessage.fromMap(e)).toList();
  }

  Future<String> uploadImage(XFile file) {
    return _api.uploadImage(file);
  }

  void sendAdminReply(String toUser, String text, {String? mediaUrl}) {
    _socket.sendMessage(
      receiverName: toUser,
      content: text,
      messageType: mediaUrl != null ? 'IMAGE' : 'TEXT',
      mediaUrl: mediaUrl,
    );
  }

  // --- CÁC HÀM XỬ LÝ REALTIME ---

//   void startSocketConnection(String token, Function(Map<String, dynamic>) onNewMessage) {
//     _onMessageReceived = onNewMessage;
//     _socket.connect(
//       token: token,
//       onGlobalMessage: (data) {
//         if (_onMessageReceived != null) {
//           _onMessageReceived!(data);
//         }
//       },
//     );
//   }
    void startSocketConnection(
      String token,
      Function(Map<String, dynamic>) onNewMessage,
      Function(Map<String, dynamic>) onReaction,
    ) {
      _onMessageReceived = onNewMessage;
      _onReactionReceived = onReaction;

      _socket.connect(
        token: token,
        onMessage: (data) {
          _onMessageReceived?.call(data);
        },
        onReaction: (data) {
          _onReactionReceived?.call(data);
        },
      );
    }

  // MỚI: Cập nhật callback khi đổi màn hình (ví dụ vào ChatDetail)
  void updateCallbacks({
    Function(Map<String, dynamic>)? onMessage,
    Function(Map<String, dynamic>)? onReaction,
  }) {
    if (onMessage != null) {
      _onMessageReceived = onMessage;
    }
    if (onReaction != null) {
      _onReactionReceived = onReaction;
    }

    print("🔄 [Repository] Updated callbacks");
  }

  void dispose() {
    _onMessageReceived = null;
    _socket.disconnect();
  }
}
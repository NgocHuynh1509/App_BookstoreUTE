import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/api_client.dart';

class SocketService {
  final ApiClient _apiClient;
  StompClient? _client;

  SocketService(this._apiClient);

  void connect({
    required String token,
      required Function(Map<String, dynamic>) onMessage,
      required Function(Map<String, dynamic>) onReaction,
      String? manualUrl,
  }) {
    try {
      print("🚀 [Socket] Bắt đầu khởi chạy hàm connect...");
      // In ra để kiểm tra token có rỗng không
            print("🔑 [Socket] Token sử dụng: ${token}...");

      // 1. Xác định Base URL
      String baseUrl = _apiClient.dio.options.baseUrl;
      if (baseUrl.isEmpty && manualUrl != null) {
        baseUrl = manualUrl;
      }

      // Nếu vẫn trống (trường hợp hiếm), dùng mặc định của máy ảo Android để không crash
      if (baseUrl.isEmpty) {
        baseUrl = "http://10.0.2.2:8080";
        print("⚠️ [Socket] BaseUrl trống, dùng mặc định: $baseUrl");
      }

      // 2. Làm sạch URL
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Loại bỏ tiền tố /api nếu có để khớp với registry.addEndpoint("/ws-bookstore")
      String wsBaseUrl = baseUrl;
      if (wsBaseUrl.contains('/api')) {
        wsBaseUrl = wsBaseUrl.replaceAll('/api', '');
      }

      // Chuyển đổi giao thức an toàn
      String cleanDomain = wsBaseUrl.replaceFirst(RegExp(r'https?://'), '');
      String wsProtocol = wsBaseUrl.startsWith('https') ? 'wss' : 'ws';

      // Tạo đường dẫn chuẩn: ws://domain:port/ws-bookstore/websocket
      final String socketUrl = '$wsProtocol://$cleanDomain/ws-bookstore/websocket';

      print("🌐 [Socket] Mục tiêu kết nối: $socketUrl");

      _client = StompClient(
        config: StompConfig(
          url: socketUrl,
          onConnect: (StompFrame frame) {
            print("✅ [Socket] KẾT NỐI THÀNH CÔNG! Đang lắng nghe...");

            // SUBSCRIBE: Khớp với convertAndSendToUser của Backend
            _client?.subscribe(
              destination: '/user/queue/messages',
              callback: (frame) {
                if (frame.body != null) {
                  print("📩 [Socket] Nhận tin nhắn riêng: ${frame.body}");
                  onMessage(json.decode(frame.body!));
                }
              },
            );

            // reaction
            _client?.subscribe(
              destination: '/user/queue/reactions',
              callback: (frame) {
                if (frame.body != null) {
                    print("📩 [Socket] Nhận reaction riêng: ${frame.body}");
                  onReaction(json.decode(frame.body!));
                }
              },
            );
          },

          // --- SỬA KHÚC NÀY ---
                    // 1. Thêm cả Authorization viết hoa và thường để bypass các Proxy/Server kén header
                    stompConnectHeaders: {
                      'Authorization': 'Bearer $token',
                      'authorization': 'Bearer $token', // Thêm bản viết thường
                    },
                    // 2. Một số môi trường web/mobile cần header ở cấp độ WebSocket
                    webSocketConnectHeaders: {
                      'Authorization': 'Bearer $token',
                      'authorization': 'Bearer $token',
                    },

                    // --- THÊM CÁI NÀY ĐỂ DEBUG ---
                    onStompError: (StompFrame frame) {
                      print("❌ [Socket] Lỗi STOMP từ Server: ${frame.body}");
                      print("Header lỗi: ${frame.headers}");
                    },
                    onWebSocketError: (dynamic error) => print("❌ [Socket] Lỗi kết nối vật lý: $error"),
                    // ------------------------

                    heartbeatIncoming: const Duration(milliseconds: 5000),
                    heartbeatOutgoing: const Duration(milliseconds: 5000),
        ),
      );

      _client?.activate();
      print("🔌 [Socket] Lệnh activate() đã được gửi.");

    } catch (e, stack) {
      print("❌ [Socket] Lỗi nghiêm trọng khi khởi tạo: $e");
      print(stack);
    }
  }

  void sendMessage({
      required String receiverName,
      required String content,
      String messageType = 'TEXT',
      String? mediaUrl,
      String? replyToId,
    }) {
      if (_client != null && _client!.connected) {
        final payload = {
          'userName': 'admin',
          'receiverName': receiverName,
          'senderRole': 'ADMIN',
          'content': content,
          'messageType': messageType,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (replyToId != null) 'replyToId': replyToId,
          'timestamp': DateTime.now().toIso8601String(),
        };

        _client?.send(
          destination: '/app/chat.sendMessage',
          body: json.encode(payload),
        );
        print("📤 [Socket] Đã gửi tới $receiverName: $content");
      } else {
        print("⚠️ [Socket] Chưa kết nối, không thể gửi tin!");
      }
    }
  void sendReaction({
    required String messageId,
    required String reaction,
    required String partnerName,
  }) {
    if (_client != null && _client!.connected) {
      final payload = {
        'messageId': messageId,
        'reaction': reaction,
        'partnerName': partnerName,
      };

      _client!.send(
        destination: '/app/chat.react',
        body: json.encode(payload),
      );

      print("📤 [Socket] Gửi reaction: $payload");
    }
  }

  void disconnect() {
    _client?.deactivate();
    print("🔌 [Socket] Đã ngắt kết nối.");
  }

  bool get isConnected => _client?.connected ?? false;
}
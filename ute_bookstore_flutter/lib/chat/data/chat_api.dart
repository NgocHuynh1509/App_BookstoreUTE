import 'package:dio/dio.dart';
import 'package:cross_file/cross_file.dart';
import '../../core/api_client.dart';

class ChatApi {
  final ApiClient _client;
  ChatApi(this._client);

  // Lấy danh sách tất cả các cuộc hội thoại (Chat List)
  Future<List<dynamic>> getChatThreads() async {
    final response = await _client.dio.get('/admin/chat/threads');
    return response.data as List<dynamic>;
  }

  // Lấy lịch sử tin nhắn với một khách hàng cụ thể
  Future<List<dynamic>> getChatHistory(String customerUsername) async {
    final response = await _client.dio.get('/admin/chat/history/$customerUsername');
    return response.data as List<dynamic>;
  }

  // Upload ảnh hỗ trợ cả Mobile và Web (dùng XFile và bytes)
  Future<String> uploadImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
    });
    final response = await _client.dio.post(
      '/chat/upload',
      data: formData,
    );
    return response.data; // Trả về text URL: "/chat/media/..."
  }

  // Đánh dấu đã xem toàn bộ tin nhắn
  Future<void> markSeen(String customerUsername) async {
    await _client.dio.post('/admin/chat/mark-seen/$customerUsername');
  }

  // Bật/tắt đánh dấu chưa đọc thủ công
  Future<void> toggleUnread(String customerUsername, bool isUnread) async {
    await _client.dio.post(
      '/admin/chat/toggle-unread/$customerUsername',
      queryParameters: {'isUnread': isUnread},
    );
  }

  // Kiểm tra xem có bất kỳ tin nhắn chưa đọc nào không
  Future<bool> getUnreadStatus() async {
    final response = await _client.dio.get('/admin/chat/unread-status');
    return response.data == true;
  }
}
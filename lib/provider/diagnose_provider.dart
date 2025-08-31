import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:plantify/services/user_service.dart';
import '../models/chat_message.dart';
import '../services/diagnose_service.dart';

class DiagnoseProvider extends ChangeNotifier {
  final service = DiagnoseService();
  final _token = UserService.getToken();

  final List<ChatMessage> _messages = [];
  bool _sending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;

  Future<void> sendText(String text, {bool isfromiamge = false}) async {
    print('==== gui text');
    final t = text.trim();
    if (t.isEmpty || _sending) return;
    print('==== guiii text');
    if (isfromiamge == false) _messages.add(ChatMessage.userText(t));
    _sending = true;
    _messages.add(ChatMessage.bot("Đang tìm câu trả lời..."));
    notifyListeners();

    try {
      final res = await service.sendText(t, _token);
      _messages.removeLast();
      if (res['success'] == true) {
        final display = (res['display'] as String?) ?? 'Đã nhận phản hồi.';
        print(display);
        _messages.add(ChatMessage.bot(display));
      } else {
        _messages.add(ChatMessage.bot('Xin lỗi, đã xảy ra lỗiê'));
      }
    } catch (e) {
      _messages.add(ChatMessage.bot('Xin lỗi, đã xảy ra lỗi $e'));
      notifyListeners();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> sendImage(File file) async {
    print('==== gui anh');
    if (_sending) return;

    _messages.add(ChatMessage.userImage(file));
    _messages.add(ChatMessage.bot("Đang phân tích ảnh..."));
    notifyListeners();

    try {
      final res = await service.sendImage(file, _token);
      if (res['success'] == true) {
        sendText(res['display'] as String, isfromiamge: true);
      } else {
        _messages.add(ChatMessage.bot("Lỗi tải ảnh"));
      }
    } catch (e) {
      _messages.add(ChatMessage.bot('Không gửi được ảnh'));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}

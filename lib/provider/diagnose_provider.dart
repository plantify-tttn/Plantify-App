import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:plantify/services/user_service.dart';
import '../models/chat_message.dart';
import '../services/diagnose_service.dart';

class DiagnoseProvider extends ChangeNotifier {
  final Box<ChatMessage> _box;
  final DiagnoseService service = DiagnoseService();
  final String _token = UserService.getToken();
  String _chatId = '';
  String get chatId => _chatId;


  DiagnoseProvider([Box<ChatMessage>? box])
      : _box = box ?? Hive.box<ChatMessage>('diagnose_messages') {
    assert(Hive.isBoxOpen('diagnose_messages'),
        'diagnose_messages box must be opened before creating DiagnoseProvider');
    _messages = _box.values.toList(growable: true);
  }

  List<ChatMessage> _messages = [];
  bool _sending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;

  int _append(ChatMessage m) {
    _messages.add(m);
    _box.add(m);
    return _messages.length - 1; 
  }
  Future<void> _removeAt(int idx) async {
    if (idx < 0 || idx >= _messages.length) return;
    _messages.removeAt(idx);
    if (idx < _box.length) {
      await _box.deleteAt(idx);
    } else {
      await _reSyncAll();
    }
  }
  Future<void> _replaceAt(int idx, ChatMessage m) async {
    if (idx < 0 || idx >= _messages.length) return;
    _messages[idx] = m;
    if (idx < _box.length) {
      await _box.putAt(idx, m);
    } else {
      await _reSyncAll();
    }
  }

  Future<void> _removeLast() async {
    if (_messages.isEmpty) return;
    final lastIdx = _messages.length - 1;
    _messages.removeLast();
    if (lastIdx < _box.length) {
      await _box.deleteAt(lastIdx);
    } else {
      await _reSyncAll();
    }
  }

  Future<void> _replaceLast(ChatMessage m) async {
    if (_messages.isEmpty) return;
    final lastIdx = _messages.length - 1;
    _messages[lastIdx] = m;

    if (lastIdx < _box.length) {
      await _box.putAt(lastIdx, m);
    } else {
      await _reSyncAll();
    }
  }

  Future<void> _reSyncAll() async {
    await _box.clear();
    await _box.addAll(_messages);
  }

  Future<void> clear() async {
    _messages.clear();
    await _box.clear();
    notifyListeners();
  }

  Future<void> sendText(String text, {bool isfromiamge = false}) async {
    final vmText = text.trim();
    if (vmText.isEmpty || _sending) return;

    if (!isfromiamge) _append(ChatMessage.userText(vmText));
    _sending = true;
    _append(ChatMessage.bot("Đang tìm câu trả lời..."));
    notifyListeners();

    try {
      final res = await service.sendText(vmText, _token, _chatId);
      await _removeLast();

      if (res['success'] == true) {
        final display = (res['display'] as String?) ?? 'Đã nhận phản hồi.';
        final options = (res['options'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();

        _append(ChatMessage.bot(display, options: options));
      } else {
        _append(ChatMessage.bot('Vui lòng chọn hoặc chụp 1 hình ảnh của bệnh để bắt đầu'));
      }
    } catch (e) {
      _append(ChatMessage.bot('Xin lỗi, đã xảy ra lỗi $e'));
    } finally {
      _sending = false;
      notifyListeners();
    }
  } 

  Future<void> sendTextInit(String text, {bool isfromiamge = false}) async {
    final vmText = text.trim();
    if (vmText.isEmpty || _sending) return;

    if (!isfromiamge) _append(ChatMessage.userText(vmText));
    _sending = true;
    _append(ChatMessage.bot("Đang tìm câu trả lời..."));
    notifyListeners();

    try {
      final res = await service.sendTextInit(vmText, _token);
      await _removeLast();
      if (res['success'] == true) {
        _chatId = res['chatId'];
        final display = (res['display'] as String?) ?? 'Đã nhận phản hồi.';
        final options = (res['options'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();
        _append(ChatMessage.bot(display, options: options));
      } else {
        _append(ChatMessage.bot('Xin lỗi, đã xảy ra lỗi'));
      }
    } catch (e) {
      _append(ChatMessage.bot('Xin lỗi, đã xảy ra lỗi $e'));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> sendImage(File file) async {
    if (_sending) return;

    _append(ChatMessage.userImage(file));
    final analyzingIdx = _append(ChatMessage.bot("Đang phân tích ảnh..."));
    notifyListeners();

    try {
      final res = await service.sendImage(file, _token);

      if (res['success'] == true) {
        await sendTextInit(res['display'] as String, isfromiamge: true);
        await _removeAt(analyzingIdx); 
      } else {
        await _replaceAt(analyzingIdx, ChatMessage.bot("Không phát hiện được bệnh, hãy cho tôi biết thông tin rõ hơn về bệnh của bạn"));
      }
    } catch (e) {
      await _replaceAt(analyzingIdx, ChatMessage.bot('Không gửi được ảnh'));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}

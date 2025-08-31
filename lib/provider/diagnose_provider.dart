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

  // Lấy box từ Hive nếu không truyền vào (đã open trong initHive)
  DiagnoseProvider([Box<ChatMessage>? box])
      : _box = box ?? Hive.box<ChatMessage>('diagnose_messages') {
    // Nếu sợ bị gọi trước initHive(), có thể thêm assert để bắt lỗi dev:
    assert(Hive.isBoxOpen('diagnose_messages'),
        'diagnose_messages box must be opened before creating DiagnoseProvider');
    _messages = _box.values.toList(growable: true);
  }

  List<ChatMessage> _messages = [];
  bool _sending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get sending => _sending;

  // ---------- Persistence helpers ----------
  int _append(ChatMessage m) {
    _messages.add(m);
    _box.add(m);
    return _messages.length - 1; // <-- trả index
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
      // rare fallback if out of sync
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

  // ---------- Public API ----------
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
      final res = await service.sendText(vmText, _token);

      // remove typing bubble (the last one)
      await _removeLast();

      if (res['success'] == true) {
        final display = (res['display'] as String?) ?? 'Đã nhận phản hồi.';
        final options = (res['options'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();

        _append(ChatMessage.bot(display, options: options));
      } else {
        _append(ChatMessage.bot('Xin lỗi, đã xảy ra lỗi'));
      }
    } catch (e) {
      // nếu removeLast thất bại trước đó, vẫn append lỗi để không “mất” log
      _append(ChatMessage.bot('Xin lỗi, đã xảy ra lỗi $e'));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> sendImage(File file) async {
    if (_sending) return;

    _append(ChatMessage.userImage(file));
    final analyzingIdx = _append(ChatMessage.bot("Đang phân tích ảnh...")); // <-- giữ index
    notifyListeners();

    try {
      final res = await service.sendImage(file, _token);

      if (res['success'] == true) {
        // Gửi câu “display” như input để bot trả lời
        await sendText(res['display'] as String, isfromiamge: true);

        // Bây giờ xóa đúng bubble "Đang phân tích ảnh..."
        await _removeAt(analyzingIdx); // <-- xóa theo index
      } else {
        await _replaceAt(analyzingIdx, ChatMessage.bot("Lỗi tải ảnh"));
      }
    } catch (e) {
      await _replaceAt(analyzingIdx, ChatMessage.bot('Không gửi được ảnh'));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}

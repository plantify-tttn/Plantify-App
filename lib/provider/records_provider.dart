import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantify/models/history_model.dart';
import 'package:plantify/models/record_model.dart';
import 'package:plantify/services/identify_service.dart';
import 'package:plantify/services/records_service.dart';
import 'package:plantify/services/user_service.dart';

class RecordsProvider extends ChangeNotifier {
  RecordsProvider({RecordsService? service})
      : _service = service ?? RecordsService();

  final RecordsService _service;
  final Box<RecordModel> _box = Hive.box<RecordModel>('records_box');

  List<RecordModel> _records = const [];
  List<RecordModel> get records => UnmodifiableListView(_records);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  bool _disposed = false;
  Future<void>? _inflight; // gộp các lần load() liên tiếp
  final _picker = ImagePicker();
  bool _busy = false;
  bool get busy => _busy;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load({bool refresh = false}) async {
    // 1) hiển thị cache nếu có
    if (!refresh && _records.isEmpty && _box.isNotEmpty) {
      _records = _box.values.toList(growable: false);
      _safeNotify();
    }

    // 2) gộp các lời gọi trùng
    if (_inflight != null) return _inflight;

    // 3) chỉ show spinner khi chưa có dữ liệu để hiển thị
    final shouldSpin = _records.isEmpty;
    if (shouldSpin) {
      _loading = true;
      _error = null;
      _safeNotify();
    }

    _inflight = _loadNetwork().whenComplete(() => _inflight = null);
    return _inflight!;
  }

  Future<void> _loadNetwork() async {
    try {
      final token = UserService.getToken();
      final data = await _service.fetchAll(token: token);

      // Ghi Hive nhanh bằng putAll
      await _box.clear();
      await _box.putAll({for (final r in data) r.id: r});

      _records = data;
    } catch (e) {
      _error = 'Không thể tải records: $e';
    } finally {
      _loading = false;
      _safeNotify();
    }
  }

  Future<void> addNew({
    required String name,
    String image = 'https://example.com/tomato.png',
  }) async {
    try {
      final token = UserService.getToken();
      final r = await _service.create(token: token, name: name.trim(), image: image);
      await _box.put(r.id, r);
      _records = _box.values.toList(growable: false);
      _safeNotify();
    } catch (e) {
      _error = 'Tạo record thất bại: $e';
      _safeNotify();
    }
  }
  Future<void> addHistoryFromCameraOrGallery({
    required String recordId,
    required bool fromCamera,
  }) async {
    if (_busy) return;
    _busy = true; notifyListeners();

    try {
      final x = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, maxWidth: 2000,
      );
      if (x == null) return;

      final token = UserService.getToken();

      final historyId = await IdentifyService().sendSeedImage(File(x.path), token);
      if (historyId.isEmpty) { throw Exception('Không nhận được historyId'); }

      // 2) Gắn historyId đó vào tracking/record
      await _service.attachHistory(token: token, recordId: recordId, historyIds: [historyId]);

      // 3) Cập nhật local (append tối thiểu để thấy ngay trên UI)
      final current = _box.get(recordId);
      if (current != null) {
        final newEntry = HistoryModel(
          id: historyId,
          userId: current.userId,
          detectType: '', // có thể fetch chi tiết sau
          label: '',
          createdAt: DateTime.now(),
          imageUrl: x.path, // tạm dùng ảnh local vừa up
        );
        final updated = current.copyWith(history: [newEntry, ...current.history]);
        await _box.put(recordId, updated);
        _records = _box.values.toList(growable: false);
      }
    } catch (e) {
      _error = 'Thêm lịch sử thất bại: $e';
    } finally {
      _busy = false; notifyListeners();
    }
  }

  RecordModel? getById(String id) => _box.get(id);
}

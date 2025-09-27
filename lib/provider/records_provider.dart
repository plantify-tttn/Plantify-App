// lib/provider/records_provider.dart
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantify/models/analysis_result.dart';
import 'package:plantify/models/record_model.dart';
import 'package:plantify/models/record_timeline_item.dart';
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

  final Map<String, List<RecordTimelineItem>> _timelineByRecord = {};
  final Set<String> _timelineLoading = {};

  final Map<String, AnalysisResult> _analysisByRecord = {};
  final Set<String> _analysisLoading = {};
  AnalysisResult? analysisOf(String recordId) => _analysisByRecord[recordId];
  bool analysisLoading(String recordId) => _analysisLoading.contains(recordId);


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
    if (_inflight != null) return _inflight!;

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
    String image = 'https://i.pinimg.com/736x/a1/e7/be/a1e7be1b7c3e5040d7170c01e8c62b36.jpg',
    List<String> selectedHistoryIds = const [],
  }) async {
    try {
      final token = UserService.getToken();
      final r = await _service.create(
        token: token,
        name: name.trim(),
        image: image,
      );
      RecordModel updated = r;
      if (selectedHistoryIds.isNotEmpty) {
        await _service.attachHistory(
          token: token,
          recordId: r.id,
          historyIds: selectedHistoryIds,
        );
        updated = r.copyWith(history: [...selectedHistoryIds, ...r.history]);
      }
      await _box.put(updated.id, updated);
      _records = [
        updated,
        ..._records.where((e) => e.id != updated.id),
      ];

      _safeNotify();
    } catch (e) {
      _error = 'Tạo record thất bại: $e';
      _safeNotify();
    }
  }

  Future<String?> addHistoryFromCameraOrGallery({
  required String recordId,
  required bool fromCamera,
}) async {
  if (_busy) return null;
  _busy = true; _safeNotify();

  try {
    final x = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85, maxWidth: 2000,
    );
    if (x == null) return null;

    final token = UserService.getToken();

    final historyId = await IdentifyService().sendSeedImage(File(x.path), token);
    if (historyId.isEmpty) throw Exception('Không nhận được historyId');

    await _service.attachHistory(token: token, recordId: recordId, historyIds: [historyId]);

    final current = _box.get(recordId);
    if (current != null) {
      final updated = current.copyWith(
        history: [historyId, ...current.history], 
      );
      await _box.put(recordId, updated);
      _records = _box.values.toList(growable: false);
      _safeNotify();
    }

    return historyId;
  } catch (e) {
    _error = 'Thêm lịch sử thất bại: $e';
    _safeNotify();
    return null;
  } finally {
    _busy = false; _safeNotify();
  }
}

  RecordModel? getById(String id) => _box.get(id);

  List<RecordTimelineItem> timelineOf(String recordId) =>
      _timelineByRecord[recordId] ?? const [];
  bool timelineLoading(String recordId) => _timelineLoading.contains(recordId);

  Future<void> loadTimeline(String recordId, {bool refresh = false}) async {
    if (!refresh && _timelineByRecord.containsKey(recordId)) return;
    if (_timelineLoading.contains(recordId)) return;

    _timelineLoading.add(recordId);
    _safeNotify();
    try {
      final token = UserService.getToken();
      final data = await _service.fetchTimeline(token: token, recordId: recordId);
      _timelineByRecord[recordId] = data;
    } catch (e) {
      _error = 'Không thể tải timeline: $e';
    } finally {
      _timelineLoading.remove(recordId);
      _safeNotify();
    }
  }

  Future<AnalysisResult?> fetchAnalysis(String recordId) async {
    if (_analysisLoading.contains(recordId)) return _analysisByRecord[recordId];
    _analysisLoading.add(recordId);
    _safeNotify();
    try {
      final token = UserService.getToken();
      final data = await _service.analyzeRecord(token: token, recordId: recordId);
      _analysisByRecord[recordId] = data;
      return data;
    } catch (e) {
      _error = 'Không thể phân tích: $e';
      return null;
    } finally {
      _analysisLoading.remove(recordId);
      _safeNotify();
    }
  }
  Future<void> attachHistories({
    required String recordId,
    required List<String> historyIds,
  }) async {
    if (historyIds.isEmpty) return;

    try {
      final token = UserService.getToken();

      await _service.attachHistory(
        token: token,
        recordId: recordId,
        historyIds: historyIds,
      );

      final current = _box.get(recordId);
      if (current != null) {
        final merged = <String>{
          ...current.history,
          ...historyIds,
        }.toList();

        final updated = current.copyWith(history: merged);
        await _box.put(recordId, updated);
        _records = _box.values.toList(growable: false);
      }

      await loadTimeline(recordId, refresh: true);

      _safeNotify();
    } catch (e) {
      _error = 'Gắn lịch sử thất bại: $e';
      _safeNotify();
      rethrow;
    }
  }

}

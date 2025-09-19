// lib/pages/records/widget/record_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantify/models/analysis_result.dart';
import 'package:plantify/models/record_model.dart';
import 'package:plantify/models/record_timeline_item.dart';
import 'package:plantify/provider/records_provider.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:provider/provider.dart';

// dùng để lấy danh sách history & l10n (hiển thị label/ảnh)
import 'package:plantify/provider/post_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({super.key, required this.record});
  final RecordModel record;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final _dateFmt = DateFormat('yyyy-MM-dd HH:mm');

  // NGƯỠNG LỊCH SỬ TỐI THIỂU ĐỂ PHÂN TÍCH
  static const int _minHistoryForAnalysis = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<SearchVm>();
      vm.getPlanItems();
      vm.getDiseaseItems();
      await context.read<RecordsProvider>().loadTimeline(widget.record.id);
    });
  }

  void _showAnalysisSheet(BuildContext context, AnalysisResult a) {
    final theme = Theme.of(context);
    final lines = a.timeline.split('\n').where((e) => e.trim().isNotEmpty).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Kết luận AI',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                if (lines.isNotEmpty) ...[
                  Text('Timeline', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  ...lines.map((l) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(l)),
                        ],
                      )),
                  const SizedBox(height: 16),
                ],
                Text('Đánh giá', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(a.answer),
                const SizedBox(height: 16),
                Text('Chi tiết', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(a.detail),
                const SizedBox(height: 16),
                Text('Khuyến nghị', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(a.suggest),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== Thêm lịch sử bằng bottom-sheet (đã đánh dấu các mục đã gắn) =====
  Future<void> _onAddHistory(BuildContext context, RecordModel r) async {
    // truyền danh sách history đã có của record để sheet đánh dấu sẵn
    final picks = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HistoryPickerSheet(alreadySelected: r.history.toSet()),
    );

    if (picks == null || picks.isEmpty) return;

    try {
      await context.read<RecordsProvider>().attachHistories(
            recordId: r.id,
            historyIds: picks.toList(), // chỉ các mục mới
          );
      if (!mounted) return;
      await context.read<RecordsProvider>().loadTimeline(r.id, refresh: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gắn ${picks.length} lịch sử vào hồ sơ')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gắn lịch sử thất bại: $e')),
      );
    }
  }

  Widget _thumb(String url) {
    final img = url.startsWith('http')
        ? Image.network(
            url,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _broken(),
          )
        : Image.file(
            File(url),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _broken(),
          );
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: img);
  }

  Widget _broken() => Container(
        width: 120,
        height: 120,
        alignment: Alignment.center,
        color: Colors.black12,
        child: const Icon(Icons.broken_image),
      );

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<RecordsProvider>();
    final r = pv.getById(widget.record.id) ?? widget.record;

    final isLoading = pv.timelineLoading(r.id);
    final List<RecordTimelineItem> items = pv.timelineOf(r.id);

    final canAnalyze = items.length >= _minHistoryForAnalysis;
    final lacking = (_minHistoryForAnalysis - items.length).clamp(0, 99);

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: RefreshIndicator(
        onRefresh: () => context.read<RecordsProvider>().loadTimeline(r.id, refresh: true),
        child: isLoading && items.isEmpty
            ? const ListTile(
                title: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : (items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildRecordHeader(context, r),
                      const SizedBox(height: 12),
                      _empty('Chưa có lịch sử cho hồ sơ này'),
                      const SizedBox(height: 12),
                      _addHistoryButton(context, r),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length + 2,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildRecordHeader(context, r);

                      if (index <= items.length) {
                        final t = items[index - 1];
                        return _timelineCard(context, t);
                      }

                      // Footer: Thêm lịch sử + (nếu đủ) Phân tích, ngược lại hiển thị gợi ý còn thiếu
                      return Column(
                        children: [
                          _addHistoryInlineButton(context, r),
                          const SizedBox(height: 8),
                          if (canAnalyze)
                            _analyzeButton(context, r.id)
                          else
                            _hintNeedMoreHistory(lacking),
                        ],
                      );
                    },
                  )),
      ),
    );
  }

  Widget _buildRecordHeader(BuildContext context, RecordModel r) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: r.image.isEmpty
            ? const CircleAvatar(child: Icon(Icons.folder))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  r.image,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
        title:
            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 4),
            Text(DateFormat('dd/MM/yyyy • HH:mm').format(r.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _timelineCard(BuildContext context, RecordTimelineItem t) {
    final isDisease = t.detectType == 'diseases';
    final title = isDisease
        ? (t.diseases?.isNotEmpty == true ? t.diseases! : 'Bệnh')
        : 'Kết quả nhận diện';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _thumb(t.imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      if (isDisease && (t.severity?.isNotEmpty ?? false))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('Mức độ bệnh: '),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.severity!,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    _dateFmt.format(t.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(text, style: const TextStyle(color: Colors.grey)),
        ),
      );

  // ===== Buttons & Hints =====

  Widget _addHistoryButton(BuildContext context, RecordModel r) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.center,
        child: FilledButton.icon(
          onPressed: () => _onAddHistory(context, r),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Thêm lịch sử'),
        ),
      ),
    );
  }

  Widget _addHistoryInlineButton(BuildContext context, RecordModel r) {
    return Align(
      alignment: Alignment.center,
      child: OutlinedButton.icon(
        onPressed: () => _onAddHistory(context, r),
        icon: const Icon(Icons.add),
        label: const Text('Thêm lịch sử'),
      ),
    );
  }

  Widget _hintNeedMoreHistory(int lacking) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Text('Cần tối thiểu $_minHistoryForAnalysis lịch sử để phân tích'
              '${lacking > 0 ? ' • Thiếu $lacking' : ''}'),
        ],
      ),
    );
  }

  Widget _analyzeButton(BuildContext context, String recordId) {
    final p = context.watch<RecordsProvider>();
    final loading = p.analysisLoading(recordId);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.center,
        child: FilledButton.icon(
          onPressed: loading
              ? null
              : () async {
                  final res =
                      await context.read<RecordsProvider>().fetchAnalysis(recordId);
                  if (!mounted) return;
                  if (res == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phân tích thất bại')),
                    );
                    return;
                  }
                  _showAnalysisSheet(context, res);
                },
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.analytics_outlined),
          label: const Text('Phân tích'),
        ),
      ),
    );
  }
}

// =============================
// Bottom-sheet chọn lịch sử (đánh dấu mục đã gắn)
// =============================
class _HistoryPickerSheet extends StatefulWidget {
  const _HistoryPickerSheet({required this.alreadySelected});
  final Set<String> alreadySelected; // các history đã gắn sẵn với record

  @override
  State<_HistoryPickerSheet> createState() => _HistoryPickerSheetState();
}

class _HistoryPickerSheetState extends State<_HistoryPickerSheet> {
  // các mục NEW user chọn thêm trong lần này (không gồm alreadySelected)
  final Set<String> _selectedNew = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostProvider>().getHistory();
      context.read<SearchVm>().getDiseaseItems();
    });
  }

  String _fmt(DateTime dt) => DateFormat('yyyy-MM-dd HH:mm').format(dt);

  String _diseaseDisplayName({
    required String label,
    required SearchVm vm,
    required Locale locale,
  }) {
    if (label.isEmpty) return '(Chưa xác định)';
    final idx = vm.allDiseaseItems.indexWhere((t) => t.id == label);
    if (idx != -1) {
      return vm.allDiseaseItems[idx].localizedName(locale);
    }
    return label; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = mq.size.height * 0.8;
    final locale = Localizations.localeOf(context);
    final local = AppLocalizations.of(context)!; // nếu đã gen l10n

    return SizedBox(
      height: height,
      child: Consumer2<PostProvider, SearchVm>(
        builder: (context, pp, vm, _) {
          // chỉ lấy lịch sử bệnh
          final histories = pp.history.where((h) => h.detectType != 'seed').toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chọn lịch sử phát hiện (Bệnh)'),
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  // Trả về CHỈ các mục mới để attach
                  onPressed: () => Navigator.pop(context, _selectedNew),
                  child: const Text('Xong'),
                ),
              ],
            ),
            body: histories.isEmpty
                ? const Center(child: Text('Chưa có lịch sử bệnh'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: histories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final h = histories[i];
                      final already = widget.alreadySelected.contains(h.id);
                      final checked = already || _selectedNew.contains(h.id);

                      final detectText = _diseaseDisplayName(
                        label: h.label,
                        vm: vm,
                        locale: locale,
                      );

                      return Opacity(
                        opacity: already ? 0.7 : 1.0,
                        child: CheckboxListTile(
                          value: checked,
                          // nếu đã gắn rồi -> disable toggle
                          onChanged: already
                              ? null
                              : (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedNew.add(h.id);
                                    } else {
                                      _selectedNew.remove(h.id);
                                    }
                                  });
                                },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${local.detect}: $detectText',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: h.label.isEmpty ? Colors.red : null,
                                  ),
                                ),
                              ),
                              if (already)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: Colors.green.withOpacity(.4)),
                                  ),
                                  child: const Text(
                                    'ĐÃ GẮN',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            _fmt(h.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          secondary: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              h.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, _selectedNew),
                  icon: const Icon(Icons.check),
                  label: Text('Gắn thêm ${_selectedNew.length} mục vào hồ sơ'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

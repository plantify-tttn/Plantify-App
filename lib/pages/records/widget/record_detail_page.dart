// lib/pages/records/widget/record_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantify/models/analysis_result.dart';
import 'package:plantify/models/record_model.dart';
import 'package:plantify/models/record_timeline_item.dart'; // 👈 model timeline
import 'package:plantify/provider/records_provider.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({super.key, required this.record});
  final RecordModel record;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final _dateFmt = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // nếu cần vẫn nạp plant/disease để dùng tên bản địa hoá (tùy bạn)
      final vm = context.read<SearchVm>();
      vm.getPlanItems();
      vm.getDiseaseItems();

      // 🔑 nạp timeline theo recordId
      await context.read<RecordsProvider>().loadTimeline(widget.record.id);
    });
  }

  void _showAnalysisSheet(BuildContext context, AnalysisResult a) {
    final theme = Theme.of(context);
    final lines =
        a.timeline.split('\n').where((e) => e.trim().isNotEmpty).toList();

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
                  Icon(Icons.analytics_outlined,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Kết luận AI',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
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
    final local = AppLocalizations.of(context)!;

    // luôn lấy bản record mới nhất nếu có
    final r = pv.getById(widget.record.id) ?? widget.record;

    final isLoading = pv.timelineLoading(r.id);
    final List<RecordTimelineItem> items = pv.timelineOf(r.id);

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<RecordsProvider>().loadTimeline(r.id, refresh: true),
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
                      _empty('Chưa có kết quả trong thư mục này'),
                      const SizedBox(height: 12),
                      _analyzeButton(context, r.id),
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
                      return _analyzeButton(context, r.id);
                    },
                  )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pv.busy
            ? null
            : () async {
                final src = await showModalBottomSheet<bool>(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: Text(local.takePhoto),
                          onTap: () => Navigator.pop(context, true),
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: Text(local.choosePhoto),
                          onTap: () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                  ),
                );
                if (src == null) return;

                await context
                    .read<RecordsProvider>()
                    .addHistoryFromCameraOrGallery(
                        recordId: r.id, fromCamera: src);

                if (!mounted) return;
                await context
                    .read<RecordsProvider>()
                    .loadTimeline(r.id, refresh: true);
              },
        icon: const Icon(Icons.add_a_photo),
        label: Text(pv.busy ? '...' : local.takePhoto),
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
                  // chips
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      if (isDisease && (t.severity?.isNotEmpty ?? false))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Mức độ bênh: '),
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

                  // title
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),

                  // time
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

  Widget _analyzeButton(BuildContext context, String recordId) {
    final p = context.watch<RecordsProvider>();
    final loading = p.analysisLoading(recordId);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: loading
              ? null
              : () async {
                  final res = await context
                      .read<RecordsProvider>()
                      .fetchAnalysis(recordId);
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

// lib/pages/records/widget/record_detail_page.dart
import 'dart:io'; // 👈 thêm
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantify/models/record_model.dart';
import 'package:plantify/models/history_model.dart';
import 'package:plantify/provider/records_provider.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// remove các import không dùng: go_router, router_name, identify_page

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SearchVm>();
      vm.getPlanItems();
      vm.getDiseaseItems();
    });
  }

  String _detectText(BuildContext context, HistoryModel h) {
    final vm = context.read<SearchVm>();
    if (h.label.isEmpty) return AppLocalizations.of(context)!.unDetect;
    if (h.detectType == 'seed') {
      final i = vm.allPlanItems.indexWhere((t) => t.id == h.label);
      if (i != -1) return vm.allPlanItems[i]
          .localizedName(Localizations.localeOf(context));
    } else {
      final j = vm.allDiseaseItems.indexWhere((t) => t.id == h.label);
      if (j != -1) return vm.allDiseaseItems[j]
          .localizedName(Localizations.localeOf(context));
    }
    return h.label;
  }

  Widget _thumb(String url) {
    final img = url.startsWith('http')
        ? Image.network(url, width: 120, height: 120, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _broken())
        : Image.file(File(url), width: 120, height: 120, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _broken());
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: img);
  }

  Widget _broken() => Container(
        width: 120, height: 120,
        alignment: Alignment.center,
        color: Colors.black12,
        child: const Icon(Icons.broken_image),
      );

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<RecordsProvider>();
    // 👇 luôn lấy bản mới nhất từ Provider (nếu chưa có thì fallback widget.record)
    final r = pv.getById(widget.record.id) ?? widget.record;
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: r.history.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: r.image.isEmpty
                    ? const CircleAvatar(child: Icon(Icons.local_florist))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          r.image, width: 52, height: 52, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                title: Text(r.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Row(
                  children: [
                    Icon(Icons.schedule, size: 16,
                        color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(DateFormat('dd/MM/yyyy • HH:mm').format(r.createdAt)),
                  ],
                ),
              ),
            );
          }

          final h = r.history[index - 1];
          final detect = _detectText(context, h);

          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _thumb(h.imageUrl), 
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${local.detect} $detect',
                            style: TextStyle(
                              fontSize: 14,
                              color: h.label.isEmpty ? Colors.red : null,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 6),
                        Text(_dateFmt.format(h.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<RecordsProvider>(
        builder: (_, pv, __) => FloatingActionButton.extended(
          onPressed: pv.busy
              ? null
              : () async {
                  final src = await showModalBottomSheet<bool>(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Wrap(children: [
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
                      ]),
                    ),
                  );
                  if (src == null) return;
                  await context
                      .read<RecordsProvider>()
                      .addHistoryFromCameraOrGallery(
                        recordId: r.id,
                        fromCamera: src,
                      );
                },
          icon: const Icon(Icons.add_a_photo),
          label: Text(pv.busy ? '...' : local.takePhoto),
        ),
      ),
    );
  }
}

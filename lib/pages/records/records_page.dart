// lib/pages/records/records_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantify/pages/records/widget/records_list.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:plantify/provider/records_provider.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecordsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomBarH = kBottomNavigationBarHeight; 
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<RecordsProvider>(
          builder: (context, pv, _) {
            if (pv.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (pv.error != null) {
              return Center(child: Text(pv.error!));
            }

            final items = pv.records;
            if (items.isEmpty) {
              return Center(
                child: TextButton.icon(
                  onPressed: _openCreateDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Tạo hồ sơ đầu tiên'),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<RecordsProvider>().load(),
              child: const RecordsList(),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomBarH + bottomInset + 8),
        child: FloatingActionButton.extended(
          onPressed: _openCreateDialog,
          icon: const Icon(Icons.add),
          label: const Text('Tạo hồ sơ'),
        ),
      ),
    );
  }

  Future<void> _openCreateDialog() async {
  final nameCtrl = TextEditingController();
  final Set<String> selectedHistoryIds = {};

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) {
        return AlertDialog(
          title: const Text('Tạo hồ sơ mới'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên hồ sơ',
                    hintText: 'Ví dụ: Rice Growth Tracking',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final picks = await showModalBottomSheet<Set<String>>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const _HistoryPickerSheet(),
                      );
                      if (picks != null) {
                        setSt(() {
                          selectedHistoryIds
                            ..clear()
                            ..addAll(picks);
                        });
                      }
                    },
                    icon: const Icon(Icons.history),
                    label: Text(
                      selectedHistoryIds.isEmpty
                          ? 'Chọn từ lịch sử phát hiện'
                          : 'Đã chọn ${selectedHistoryIds.length} mục',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                await context.read<RecordsProvider>().addNew(
                  name: name,
                  selectedHistoryIds: selectedHistoryIds.toList(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
    ),
  );
}
}
class _HistoryPickerSheet extends StatefulWidget {
  const _HistoryPickerSheet();

  @override
  State<_HistoryPickerSheet> createState() => _HistoryPickerSheetState();
}

class _HistoryPickerSheetState extends State<_HistoryPickerSheet> {
  final Set<String> _selected = {};

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
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final height = mq.size.height * 0.8;
    final locale = Localizations.localeOf(context);
    final local = AppLocalizations.of(context)!; 

    return SizedBox(
      height: height,
      child: Consumer2<PostProvider, SearchVm>(
        builder: (context, pp, vm, _) {
          final histories = pp.history.where((h) => h.detectType != 'seed').toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chọn lịch sử phát hiện (Bệnh)'),
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, _selected),
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
                      final checked = _selected.contains(h.id);

                      final detectText = _diseaseDisplayName(
                        label: h.label,
                        vm: vm,
                        locale: locale,
                      );

                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selected.add(h.id);
                            } else {
                              _selected.remove(h.id);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          '${local.detect}: $detectText',
                          style: TextStyle(
                            fontSize: 14,
                            color: h.label.isEmpty ? Colors.red : null,
                          ),
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
                      );
                    },
                  ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, _selected),
                  icon: const Icon(Icons.check),
                  label: Text('Gắn ${_selected.length} mục vào hồ sơ'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
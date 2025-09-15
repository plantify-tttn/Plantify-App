import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantify/pages/records/widget/record_detail_page.dart';
import 'package:plantify/pages/records/widget/records_card.dart';
import 'package:plantify/provider/records_provider.dart';
import 'package:provider/provider.dart';

class RecordsList extends StatelessWidget {
  const RecordsList({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy • HH:mm');

    return Consumer<RecordsProvider>(
      builder: (context, pv, _) {
        final records = pv.records;

        if (pv.loading) return const Center(child: CircularProgressIndicator());
        if (pv.error != null) return Center(child: Text(pv.error!));
        if (records.isEmpty) return const Center(child: Text('Chưa có hồ sơ nào.'));

        return RefreshIndicator(
          onRefresh: () => context.read<RecordsProvider>().load(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100), // 👈 chừa chỗ cho FAB
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = records[i];
              return Dismissible(
                key: ValueKey(r.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xoá hồ sơ?'),
                          content: Text('Bạn chắc chắn muốn xoá "${r.name}"?'), // 👈 name
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Huỷ'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xoá'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                // onDismissed: (_) => context.read<RecordsProvider>().delete(r.id),
                child: RecordsCard(
                  record: r,
                  dateFmt: dateFmt,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RecordDetailPage(record: r)),
                    );
                    // hoặc: context.pushNamed(RouterName.recordDetail, extra: r);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

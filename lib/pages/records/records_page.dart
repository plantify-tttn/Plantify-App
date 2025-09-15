// lib/pages/records/records_page.dart
import 'package:flutter/material.dart';
import 'package:plantify/pages/records/widget/records_list.dart';
import 'package:plantify/provider/records_provider.dart';
import 'package:provider/provider.dart';

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
    final bottomBarH = kBottomNavigationBarHeight; // ~56
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

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo hồ sơ mới'),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Tên hồ sơ',
              hintText: 'Ví dụ: Rice Growth Tracking',
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              await context.read<RecordsProvider>().addNew(name: name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}

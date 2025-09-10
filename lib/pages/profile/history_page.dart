import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<SearchVm>();
      vm.getPlanItems();            // hoặc getPlantItems nếu tên đúng
      vm.getDiseaseItems();
      context.read<PostProvider>().getHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _fmt(DateTime dt) => DateFormat('yyyy-MM-dd HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchVm>();   // <-- dùng vm
    final locale = Localizations.localeOf(context);
    final local = AppLocalizations.of(context)!;
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        final histories = postProvider.history;
        return Scaffold(
          appBar: AppBar(title: Text(local.detectHistory)),
          body: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: histories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final h = histories[index];

              PlantModel? p;
              DiseaseModel? d;

              if (h.label.isNotEmpty) {
                if (h.detectType == 'seed') {
                  final i = vm.allPlanItems.indexWhere((t) => t.id == h.label);              // <-- vm
                  if (i != -1) p = vm.allPlanItems[i];
                } else {
                  final j = vm.allDiseaseItems.indexWhere((t) => t.id == h.label);           // <-- vm
                  if (j != -1) d = vm.allDiseaseItems[j];
                }
              }

              final detectText = h.label.isEmpty
                  ? local.unDetect
                  : (p != null
                      ? p.localizedName(locale)
                      : (d != null ? d.localizedName(locale) : h.label));

              return GestureDetector(
                onTap: () {
                  if (h.label.isEmpty) return;
                  if (h.detectType == 'seed' && p != null) {
                    context.goNamed(RouterName.detailPlant, extra: p);
                  } else if (h.detectType != 'seed' && d != null) {
                    context.goNamed(RouterName.detailDisease, extra: d);
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            h.imageUrl,
                            width: 120, height: 120, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120, height: 120,
                              alignment: Alignment.center,
                              color: Colors.black12,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(local.detect + " $detectText",
                                  style: TextStyle(fontSize: 14, color: h.label.isEmpty ? Colors.red : null)),
                              const SizedBox(height: 6),
                              Text(_fmt(h.createdAt),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}


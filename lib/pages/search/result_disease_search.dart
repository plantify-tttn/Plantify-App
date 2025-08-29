import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/pages/search/search_common.dart';

class ResultDiseaseSearch extends StatelessWidget {
  final List<DiseaseModel> listItems;
  final TextEditingController searchController;

  const ResultDiseaseSearch({
    super.key,
    required this.listItems,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final query = searchController.text.trim();

    if (query.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ResultContainer(
        child: listItems.isEmpty
            ? const EmptyState(text: 'No diseases found')
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: listItems.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final item = listItems[index];
                    final img = item.images.isNotEmpty
                        ? item.images.first
                        : 'https://baonamdinh.vn/file/e7837c02816d130b0181a995d7ad7e96/082024/1_20240826084027.png';

                    return SearchTile(
                      title: item.localizedName(locale),
                      query: query,
                      imageUrl: img,
                      fallbackIcon: Icons.medical_information_rounded,
                      onTap: () => context.goNamed(
                        RouterName.detailDisease,
                        extra: item,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

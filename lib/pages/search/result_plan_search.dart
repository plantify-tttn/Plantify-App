import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/pages/search/search_common.dart';

class ResultPlanSearch extends StatelessWidget {
  final List<PlantModel> listItems;
  final TextEditingController searchController;

  const ResultPlanSearch({
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
            ? const EmptyState(text: 'No plants found')
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
                    final img = item.images.isNotEmpty ? item.images.first : null;

                    return SearchTile(
                      title: item.localizedName(locale),
                      query: query,
                      imageUrl: img,
                      fallbackIcon: Icons.eco_rounded,
                      onTap: () => context.goNamed(
                        RouterName.detailPlant,
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

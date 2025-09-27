import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/pages/search/result_disease_search.dart';
import 'package:plantify/pages/search/result_plan_search.dart';
import 'package:plantify/pages/search/trending_disease.dart';
import 'package:plantify/pages/search/trending_plant.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:plantify/widgets/textfield/search_field.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SearchVm>();
      vm.getPlanItems();
      vm.getDiseaseItems();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchVm>(
      builder: (context, searchVm, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              final vm = context.read<SearchVm>();
              await Future.wait([
                vm.getPlanItems(refetch: true),
                vm.getDiseaseItems(refetch: true),
              ]);
              final q = searchVm.searchController.text;
              if (q.isNotEmpty) {
                vm.search(q, context);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: SearchField(
                          controller: searchVm.searchController,
                          focusNode: _focusNode,
                          onChanged: (value) => searchVm.search(value, context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ResultPlanSearch(
                    listItems: searchVm.filteredPlanItems,
                    searchController: searchVm.searchController,
                  ),
                  ResultDiseaseSearch(
                    listItems: searchVm.filterDiseaseItems,
                    searchController: searchVm.searchController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.trendingPlants,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  TrendingPlant(listItems: searchVm.allPlanItems),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.trendingDisease,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  TrendingDisease(listItems: searchVm.allDiseaseItems),
                  const SizedBox(height: 24), 
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

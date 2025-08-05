import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/pages/search/result_search.dart';
import 'package:plantify/pages/search/trending_plant.dart';
import 'package:plantify/viewmodel/search_vm.dart';
import 'package:plantify/widgets/textfield/search_field.dart';
import 'package:provider/provider.dart';

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

    // Delay 1 frame để context sẵn sàng trước khi gọi focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchVm>(context, listen: false).getItems();
      _focusNode.requestFocus(); // Tự động bật bàn phím
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 45),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.goNamed(RouterName.home);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: SearchField(
                        controller: searchVm.searchController,
                        focusNode: _focusNode, // Truyền vào ô tìm kiếm
                        onChanged: searchVm.search,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ResultSearch(listItems: searchVm.filteredItems),
                TrendingPlant(listItems: searchVm.allItems,)
              ],
            ),
          ),
        );
      },
    );
  }
}

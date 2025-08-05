import 'package:flutter/material.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/services/plants_service.dart';

class SearchVm extends ChangeNotifier{
  final _searchController = TextEditingController();

  TextEditingController get searchController => _searchController;

  // Dữ liệu gốc (toàn bộ danh sách)
  List<PlantModel> _allItems = [];

  // Kết quả tìm kiếm (để hiển thị)
  List<PlantModel> _filteredItems = []; // Kết quả lọc

  List<PlantModel> get filteredItems => _filteredItems;
  List<PlantModel> get allItems => _allItems;

  bool isLoading = false;
  String? error;

  // Lấy danh sách cây từ service
  Future<void> getItems() async {
    isLoading = true;
    notifyListeners();

    try {
      final items = await PlantsService().getPlants();
      _allItems = items;
      _filteredItems = [];
      error = null;
    } catch (e) {
      error = 'Không thể tải danh sách cây';
    }

    isLoading = false;
    notifyListeners();
  }

  // Hàm tìm kiếm
  void search(String query) {
    if (query.isEmpty) {
      _filteredItems = [];
    } else {
      _filteredItems = _allItems
          .where((item) =>
              item.name.toLowerCase().contains(query.trim().toLowerCase()))
          .toList();
    }
    notifyListeners(); // Cập nhật UI
  }

  // Gọi khi dispose màn hình
  void disposeController() {
    _searchController.dispose();
    super.dispose();
  }
}
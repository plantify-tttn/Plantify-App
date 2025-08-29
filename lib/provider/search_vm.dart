import 'package:flutter/material.dart';
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/services/plants_service.dart';

class SearchVm extends ChangeNotifier {
  final _searchController = TextEditingController();

  TextEditingController get searchController => _searchController;

  // Dữ liệu gốc (toàn bộ danh sách)
  List<PlantModel> _allPlanItems = [];
  List<DiseaseModel> _allDiseaseItems = [];

  // Kết quả tìm kiếm (để hiển thị)
  List<PlantModel> _filteredPlanItems = []; // Kết quả lọc
  List<PlantModel> get filteredPlanItems => _filteredPlanItems;
  List<DiseaseModel> _filteredDiseaseItems = []; // Kết quả lọc
  List<DiseaseModel> get filterDiseaseItems => _filteredDiseaseItems;
  List<PlantModel> get allPlanItems => _allPlanItems;
  List<DiseaseModel> get allDiseaseItems => _allDiseaseItems;

  bool isLoading = false;
  String? error;

  // Lấy danh sách cây từ service
  Future<void> getPlanItems() async {
    isLoading = true;
    notifyListeners();

    if (PlantsService().getPlantsFromHive().isNotEmpty) {
      _allPlanItems = PlantsService().getPlantsFromHive();
      _filteredPlanItems = [];
      error = null;
    } else {
      try {
        final items = await PlantsService().getPlants();
        _allPlanItems = items;
        _filteredPlanItems = [];
        error = null;
      } catch (e) {
        error = 'Không thể tải danh sách cây';
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> getDiseaseItems() async {
    isLoading = true;
    notifyListeners();

    if (PlantsService().getDiseaseFromHive().isNotEmpty) {
      _allDiseaseItems = PlantsService().getDiseaseFromHive();
      _filteredDiseaseItems = [];
      error = null;
    } else {
      try {
        final items = await PlantsService().getDisease();
        _allDiseaseItems = items;
        _filteredDiseaseItems = [];
        error = null;
      } catch (e) {
        error = 'Không thể tải danh sách cây';
      }
    }
    isLoading = false;
    notifyListeners();
  }

  // Hàm tìm kiếm
  void search(String query, BuildContext context) {
    final locale = Localizations.localeOf(context); // ✅ Lấy locale hiện tại

    if (query.isEmpty) {
      _filteredPlanItems = [];
      _filteredDiseaseItems = [];
    } else {
      String nameToCheckPlan;
      String nameToCheckDisease;
      _filteredPlanItems = _allPlanItems.where((item) {
        nameToCheckPlan = locale.languageCode == 'vi' ? item.name : item.nameEn;

        return nameToCheckPlan
            .toLowerCase()
            .contains(query.trim().toLowerCase());
      }).toList();
      _filteredDiseaseItems = _allDiseaseItems.where((item) {
        nameToCheckDisease =
            locale.languageCode == 'vi' ? item.name : item.nameEn;

        return nameToCheckDisease
            .toLowerCase()
            .contains(query.trim().toLowerCase());
      }).toList();
    }

    notifyListeners(); // Cập nhật UI
  }

  // Gọi khi dispose màn hình
  void disposeController() {
    _searchController.dispose();
    super.dispose();
  }
}

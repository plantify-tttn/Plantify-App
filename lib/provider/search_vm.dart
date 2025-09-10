import 'package:flutter/material.dart';
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/services/plants_service.dart';

class SearchVm extends ChangeNotifier {
  final _searchController = TextEditingController();
  final PlantsService _service = PlantsService(); // ✅ 1 instance

  TextEditingController get searchController => _searchController;

  // Dữ liệu gốc
  List<PlantModel> _allPlanItems = [];
  List<DiseaseModel> _allDiseaseItems = [];
  List<PlantModel> get allPlanItems => _allPlanItems;
  List<DiseaseModel> get allDiseaseItems => _allDiseaseItems;

  // Kết quả tìm kiếm
  List<PlantModel> _filteredPlanItems = [];
  List<PlantModel> get filteredPlanItems => _filteredPlanItems;
  List<DiseaseModel> _filteredDiseaseItems = [];
  List<DiseaseModel> get filterDiseaseItems => _filteredDiseaseItems;

  bool isLoading = false;
  String? error;

  // Lấy danh sách cây
  Future<void> getPlanItems({bool refetch = false}) async {
    isLoading = true;
    notifyListeners();

    try {
      if (refetch) {
        await _service.clearAllPlants(); // ✅ chờ xoá xong rồi mới fetch
      }

      final cached = _service.getPlantsFromHive();
      if (cached.isNotEmpty) {
        _allPlanItems = cached;
        _filteredPlanItems = [];
        error = null;
      } else {
        final items = await _service.getPlants();
        _allPlanItems = items;
        _filteredPlanItems = [];
        error = null;
      }
    } catch (e) {
      error = 'Không thể tải danh sách cây';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh sách bệnh
  Future<void> getDiseaseItems({bool refetch = false}) async {
    isLoading = true;
    notifyListeners();

    try {
      if (refetch) {
        await _service.clearAllDiseases(); // ✅ chờ xoá xong
      }

      final cached = _service.getDiseaseFromHive();
      if (cached.isNotEmpty) {
        _allDiseaseItems = cached;
        _filteredDiseaseItems = [];
        error = null;
      } else {
        final items = await _service.getDisease();
        _allDiseaseItems = items;
        _filteredDiseaseItems = [];
        error = null;
      }
    } catch (e) {
      error = 'Không thể tải danh sách bệnh';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Tìm kiếm
  void search(String query, BuildContext context) {
    final locale = Localizations.localeOf(context);

    if (query.trim().isEmpty) {
      _filteredPlanItems = [];
      _filteredDiseaseItems = [];
    } else {
      final q = query.trim().toLowerCase();

      _filteredPlanItems = _allPlanItems.where((item) {
        final vi = (item.name).toLowerCase();
        final en = (item.nameEn).toLowerCase();
        final target = locale.languageCode == 'vi' ? vi : en;
        return target.contains(q);
      }).toList();

      _filteredDiseaseItems = _allDiseaseItems.where((item) {
        final vi = (item.name).toLowerCase();
        final en = (item.nameEn ).toLowerCase();
        final target = locale.languageCode == 'vi' ? vi : en;
        return target.contains(q);
      }).toList();
    }

    notifyListeners();
  }

  // Gọi khi dispose màn hình
  void disposeController() {
    _searchController.dispose();
    super.dispose();
  }
}

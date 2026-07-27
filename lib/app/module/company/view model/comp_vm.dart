import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/comp_model.dart';
import '../services/comp_services.dart';

class CompanyViewModel extends ChangeNotifier {
  final CompanyService _service = CompanyService();

  CompanyModel? orgChart;
  List<CompanyModel> floorMaps = [];
  bool isLoading = false;

  Future<void> fetchOrgChart(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      orgChart = await _service.getOrgChart(token);
    } catch (e) {
      debugPrint('fetchOrgChart error: $e');
      // optionally store an error message field to show in UI
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFloorMaps(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      floorMaps = await _service.getFloorMaps(token);
    } catch (e) {
      debugPrint('fetchFloorMaps error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadOrgChart(XFile image, String token) async {
    final ok = await _service.uploadOrgChart(image, token);
    if (ok) await fetchOrgChart(token);
    return ok;
  }

  Future<bool> uploadFloorMap(XFile image, String title, String token) async {
    final ok = await _service.uploadFloorMap(image, title, token);
    if (ok) await fetchFloorMaps(token);
    return ok;
  }

  Future<bool> deleteItem(int id, String token, {required bool isOrgChart}) async {
    final ok = await _service.deleteCompanyItem(id, token);
    if (ok) {
      if (isOrgChart) {
        await fetchOrgChart(token);
      } else {
        await fetchFloorMaps(token);
      }
    }
    return ok;
  }
}
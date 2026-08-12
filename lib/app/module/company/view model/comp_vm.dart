import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/comp_model.dart';
import '../services/comp_services.dart';
import '../view/widget/CompTeam.dart';

class CompanyViewModel extends ChangeNotifier {
  final CompanyService _service = CompanyService();

  CompanyModel? orgChart;
  CompanyModel? visionMission; 
  List<CompanyModel> floorMaps = [];
  List<TeamMember> teamMembers = [];
  List<DepartmentOption> departments = [];
  CompanyModel? about;
  String visionText = '';
  String missionText = '';
  bool isLoading = false;

  Future<void> fetchAll(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchOrgChart(token, notify: false),
        fetchFloorMaps(token, notify: false),
        fetchAbout(token, notify: false),
        fetchVisionMission(token, notify: false),
        fetchTeamMembers(token, notify: false),
        fetchDepartments(token, notify: false), 
      ]);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrgChart(String token, {bool notify = true}) async {
    try {
      orgChart = await _service.getOrgChart(token);
    } catch (e) {
      debugPrint('fetchOrgChart error: $e');
    }
    if (notify) notifyListeners();
  }

  Future<void> fetchFloorMaps(String token, {bool notify = true}) async {
    try {
      floorMaps = await _service.getFloorMaps(token);
    } catch (e) {
      debugPrint('fetchFloorMaps error: $e');
    }
    if (notify) notifyListeners();
  }

  Future<void> fetchAbout(String token, {bool notify = true}) async {
    try {
      about = await _service.getAbout(token);
    } catch (e) {
      debugPrint('fetchAbout error: $e');
    }
    if (notify) notifyListeners();
  }

  Future<void> fetchVisionMission(String token, {bool notify = true}) async {
    try {
      final data = await _service.getVisionMission(token);
      visionMission = data; // [NEW]
      if (data?.content != null) {
        final decoded = jsonDecode(data!.content!);
        visionText = decoded['vision'] ?? '';
        missionText = decoded['mission'] ?? '';
      }
    } catch (e) {
      debugPrint('fetchVisionMission error: $e');
    }
    if (notify) notifyListeners();
  }

  Future<bool> uploadOrgChart(XFile image, String token, {String? title}) async {
    final ok = await _service.uploadOrgChart(image, token, title: title);
    if (ok) await fetchOrgChart(token);
    return ok;
  }

  Future<bool> uploadFloorMap(XFile image, String title, String token) async {
    final ok = await _service.uploadFloorMap(image, title, token);
    if (ok) await fetchFloorMaps(token);
    return ok;
  }

  Future<bool> updateTitle(int id, String title, String token, {required bool isOrgChart}) async {
    final ok = await _service.updateTitle(id, title, token);
    if (ok) {
      if (isOrgChart) {
        await fetchOrgChart(token);
      } else {
        await fetchFloorMaps(token);
      }
    }
    return ok;
  }

  Future<bool> updateAbout(String content, String token) async {
    final ok = await _service.updateAbout(content, token);
    if (ok) await fetchAbout(token);
    return ok;
  }

  Future<bool> updateVisionMission(String vision, String mission, String token) async {
    final ok = await _service.updateVisionMission(vision, mission, token);
    if (ok) await fetchVisionMission(token);
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

  Future<bool> deleteAbout(String token) async {
    if (about == null) return false;
    final ok = await _service.deleteCompanyItem(about!.id, token);
    if (ok) {
      about = null;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> deleteVisionMission(String token) async {
    if (visionMission == null) return false;
    final ok = await _service.deleteCompanyItem(visionMission!.id, token);
    if (ok) {
      visionMission = null;
      visionText = '';
      missionText = '';
      notifyListeners();
    }
    return ok;
  }

    Future<void> fetchDepartments(String token, {bool notify = true}) async {
    try {
      departments = await _service.getDepartments(token);
    } catch (e) {
      debugPrint('fetchDepartments error: $e');
    }
    if (notify) notifyListeners();
  }

  Future<void> fetchTeamMembers(String token, {bool notify = true}) async {
    try {
      teamMembers = await _service.getTeamMembers(token);
    } catch (e) {
      debugPrint('fetchTeamMembers error: $e');
    }
    if (notify) notifyListeners();
  }

  Future<bool> addTeamMember(TeamMemberFormResult form, String token) async {
    final ok = await _service.createTeamMember(
      name: form.name,
      position: form.position,
      departmentId: form.departmentId,
      background: form.background,
      photo: form.photo,
      token: token,
    );
    if (ok) await fetchTeamMembers(token);
    return ok;
  }

  Future<bool> editTeamMember(int id, TeamMemberFormResult form, String token) async {
    final ok = await _service.updateTeamMember(
      id: id,
      name: form.name,
      position: form.position,
      departmentId: form.departmentId,
      background: form.background,
      photo: form.photo,
      token: token,
    );
    if (ok) await fetchTeamMembers(token);
    return ok;
  }

  Future<bool> removeTeamMember(int id, String token) async {
    final ok = await _service.deleteTeamMember(id, token);
    if (ok) await fetchTeamMembers(token);
    return ok;
  }
}
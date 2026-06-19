import 'package:shared_preferences/shared_preferences.dart';
import '../models/intervention_model.dart';

class StorageService {
  static const String _interventionsKey = 'interventions';
  static const String _technicienKey = 'technicien_name';
  static const String _technicienTelKey = 'technicien_tel';

  static Future<List<InterventionModel>> loadInterventions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_interventionsKey) ?? [];
    return list.map((s) => InterventionModel.fromJsonString(s)).toList()
      ..sort((a, b) => b.dateIntervention.compareTo(a.dateIntervention));
  }

  static Future<List<InterventionModel>> loadTerminees() async {
    final all = await loadInterventions();
    return all.where((m) => m.termine).toList();
  }

  static Future<void> saveIntervention(InterventionModel intervention) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_interventionsKey) ?? [];
    final idx = list.indexWhere((s) {
      try {
        return InterventionModel.fromJsonString(s).id == intervention.id;
      } catch (_) {
        return false;
      }
    });
    if (idx >= 0) {
      list[idx] = intervention.toJsonString();
    } else {
      list.add(intervention.toJsonString());
    }
    await prefs.setStringList(_interventionsKey, list);
  }

  static Future<void> deleteIntervention(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_interventionsKey) ?? [];
    list.removeWhere((s) {
      try {
        return InterventionModel.fromJsonString(s).id == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_interventionsKey, list);
  }

  static Future<String?> getTechnicienName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_technicienKey);
  }

  static Future<void> saveTechnicienName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_technicienKey, name);
  }

  static Future<String?> getTechnicienTel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_technicienTelKey);
  }

  static Future<void> saveTechnicienTel(String tel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_technicienTelKey, tel);
  }
}

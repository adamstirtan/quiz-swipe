import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/persona_data.dart';
import '../services/data_repository.dart';

class PersonaManager with ChangeNotifier {
  final DataRepository _repo = DataRepository();
  PersonaData _data = PersonaData();
  int _totalAnswered = 0;

  PersonaData get data => _data;
  int get totalAnswered => _totalAnswered;

  bool get shouldAskDemographic {
    return _totalAnswered > 0 && 
           _totalAnswered % 15 == 0 &&
           (_data.demographic == null || _data.region == null);
  }

  String? get demographicPrompt {
    if (_data.demographic == null) {
      return 'What is your age group?';
    } else if (_data.region == null) {
      return 'Where are you from?';
    }
    return null;
  }

  List<String>? get demographicChoices {
    if (_data.demographic == null) {
      return ['Under 18', '18-24', '25-34', '35-44', '45-54', '55+'];
    } else if (_data.region == null) {
      return ['North America', 'South America', 'Europe', 'Asia', 'Africa', 'Oceania'];
    }
    return null;
  }

  Future<void> restore() async {
    final storage = await SharedPreferences.getInstance();
    final demo = storage.getString('demographic');
    final reg = storage.getString('region');
    final sharing = storage.getBool('data_sharing') ?? true;
    
    _data = PersonaData(
      demographic: demo,
      region: reg,
      sharingEnabled: sharing,
    );
    
    _totalAnswered = storage.getInt('total_answered') ?? 0;
    notifyListeners();
  }

  Future<void> modify({String? demographic, String? region, bool? sharingEnabled}) async {
    final storage = await SharedPreferences.getInstance();

    if (demographic != null) {
      _data.demographic = demographic;
      await storage.setString('demographic', demographic);
    }

    if (region != null) {
      _data.region = region;
      await storage.setString('region', region);
    }

    if (sharingEnabled != null) {
      _data.sharingEnabled = sharingEnabled;
      await storage.setBool('data_sharing', sharingEnabled);
    }

    await _repo.syncPersonaData(_data.toMap());
    notifyListeners();
  }

  void incrementAnswered() {
    _totalAnswered++;
    SharedPreferences.getInstance().then((storage) {
      storage.setInt('total_answered', _totalAnswered);
    });
    notifyListeners();
  }

  Future<void> purgeAll() async {
    await _repo.purgeUserData();
    
    final storage = await SharedPreferences.getInstance();
    await storage.clear();
    
    _data = PersonaData();
    _totalAnswered = 0;
    notifyListeners();
  }
}

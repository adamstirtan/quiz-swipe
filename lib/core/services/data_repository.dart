import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_item.dart';
import '../models/response_record.dart';
import '../models/analytics.dart';

class DataRepository {
  static final DataRepository _singleton = DataRepository._construct();
  factory DataRepository() => _singleton;
  DataRepository._construct();

  late SupabaseClient _db;
  String? _deviceIdentifier;

  Future<void> setup(String endpoint, String publicKey) async {
    await Supabase.initialize(url: endpoint, anonKey: publicKey);
    _db = Supabase.instance.client;
    
    final authResponse = await _db.auth.signInAnonymously();
    _deviceIdentifier = authResponse.user?.id;
  }

  SupabaseClient get database => _db;
  String? get deviceId => _deviceIdentifier;

  Future<List<QuizItem>> fetchBatch({int size = 10, int skip = 0}) async {
    try {
      final result = await _db
          .from('questions')
          .select()
          .range(skip, skip + size - 1);

      return (result as List).map((item) => QuizItem.fromMap(item)).toList();
    } catch (error) {
      debugPrint('Fetch error: $error');
      return [];
    }
  }

  Future<void> recordResponse(ResponseRecord record) async {
    try {
      await _db.from('answers').insert(record.toMap());
    } catch (error) {
      debugPrint('Record error: $error');
    }
  }

  Future<Analytics> fetchAnalytics(String quizUid) async {
    try {
      final result = await _db.rpc('get_question_stats', params: {'question_id_param': quizUid});

      if (result != null) {
        return Analytics.fromMap(result);
      }
    } catch (error) {
      debugPrint('Analytics error: $error');
    }

    return Analytics(quizUid: quizUid, distribution: {}, totalCount: 0);
  }

  Future<void> syncPersonaData(Map<String, dynamic> data) async {
    try {
      if (_deviceIdentifier != null) {
        await _db.from('user_profiles').upsert({
          'device_id': _deviceIdentifier,
          ...data,
        });
      }
    } catch (error) {
      debugPrint('Sync error: $error');
    }
  }

  Future<void> purgeUserData() async {
    try {
      if (_deviceIdentifier != null) {
        await _db.from('answers').delete().eq('device_id', _deviceIdentifier);
        await _db.from('user_profiles').delete().eq('device_id', _deviceIdentifier);
      }
    } catch (error) {
      debugPrint('Purge error: $error');
    }
  }
}

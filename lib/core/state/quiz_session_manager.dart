import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_item.dart';
import '../models/response_record.dart';
import '../services/data_repository.dart';

class QuizSessionManager with ChangeNotifier {
  final DataRepository _repo = DataRepository();
  
  List<QuizItem> _itemQueue = [];
  int _cursor = 0;
  int _dailyCompletions = 0;
  int _consecutiveDays = 0;
  DateTime? _lastActivityDate;
  bool _fetching = false;

  List<QuizItem> get allItems => _itemQueue;
  QuizItem? get activeItem => _cursor < _itemQueue.length ? _itemQueue[_cursor] : null;
  int get dailyProgress => _dailyCompletions;
  int get streak => _consecutiveDays;
  bool get loading => _fetching;

  Future<void> loadBatch() async {
    _fetching = true;
    notifyListeners();

    try {
      final batch = await _repo.fetchBatch(size: 10, skip: _itemQueue.length);
      _itemQueue.addAll(batch);
    } catch (error) {
      print('Load batch error: $error');
    }

    _fetching = false;
    notifyListeners();
  }

  Future<void> recordAnswer(dynamic answer) async {
    if (activeItem == null) return;

    final record = ResponseRecord(
      quizUid: activeItem!.uid,
      deviceUid: _repo.deviceId,
      value: answer,
      when: DateTime.now(),
    );

    await _repo.recordResponse(record);
    
    await _updateProgress();
    
    _cursor++;
    
    if (_cursor >= _itemQueue.length - 2) {
      await loadBatch();
    }
    
    notifyListeners();
  }

  Future<void> moveNext() async {
    _cursor++;
    
    if (_cursor >= _itemQueue.length - 2) {
      await loadBatch();
    }
    
    notifyListeners();
  }

  Future<void> _updateProgress() async {
    final storage = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActivityDate == null) {
      _lastActivityDate = today;
      _dailyCompletions = 1;
      _consecutiveDays = 1;
    } else {
      final lastDay = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );

      if (today == lastDay) {
        _dailyCompletions++;
      } else if (today.difference(lastDay).inDays == 1) {
        _consecutiveDays++;
        _dailyCompletions = 1;
        _lastActivityDate = today;
      } else {
        _consecutiveDays = 1;
        _dailyCompletions = 1;
        _lastActivityDate = today;
      }
    }

    await storage.setInt('daily_count', _dailyCompletions);
    await storage.setInt('streak_days', _consecutiveDays);
    await storage.setString('last_activity', _lastActivityDate!.toIso8601String());
  }

  Future<void> restoreProgress() async {
    final storage = await SharedPreferences.getInstance();
    _dailyCompletions = storage.getInt('daily_count') ?? 0;
    _consecutiveDays = storage.getInt('streak_days') ?? 0;
    
    final savedDate = storage.getString('last_activity');
    if (savedDate != null) {
      _lastActivityDate = DateTime.parse(savedDate);
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );

      if (today != lastDay) {
        if (today.difference(lastDay).inDays > 1) {
          _consecutiveDays = 0;
        }
        _dailyCompletions = 0;
      }
    }
    
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/health_record.dart';

class HealthProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<HealthRecord> _records = [];
  List<HealthRecord> _recentRecords = [];
  HealthRecord? _latestRecord;
  int _totalRecords = 0;
  bool _isLoading = false;
  bool _isDashboardLoading = false;

  List<HealthRecord> get records => List.unmodifiable(_records);
  List<HealthRecord> get recentRecords => List.unmodifiable(_recentRecords);
  bool get isLoading => _isLoading;
  bool get isDashboardLoading => _isDashboardLoading;

  int get totalRecords => _totalRecords;
  HealthRecord? get latestRecord => _latestRecord;

  Future<void> loadDashboardData() async {
    _isDashboardLoading = true;
    notifyListeners();

    final results = await Future.wait<dynamic>([
      _databaseHelper.getHealthRecordCount(),
      _databaseHelper.getLatestHealthRecord(),
      _databaseHelper.getRecentHealthRecords(limit: 5),
    ]);

    _totalRecords = results[0] as int;
    _latestRecord = results[1] as HealthRecord?;
    _recentRecords = results[2] as List<HealthRecord>;

    _isDashboardLoading = false;
    notifyListeners();
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    _records = await _databaseHelper.getHealthRecords();
    _totalRecords = _records.length;
    _latestRecord = _records.isEmpty ? null : _records.first;
    _recentRecords = _records.take(5).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecord(HealthRecord record) async {
    await _databaseHelper.insertHealthRecord(record);
    await _refreshAfterMutation();
  }

  Future<void> updateRecord(HealthRecord record) async {
    await _databaseHelper.updateHealthRecord(record);
    await _refreshAfterMutation();
  }

  Future<void> deleteRecord(int id) async {
    await _databaseHelper.deleteHealthRecord(id);
    await _refreshAfterMutation();
  }

  Future<void> _refreshAfterMutation() {
    return _records.isEmpty ? loadDashboardData() : loadRecords();
  }

  Future<HealthRecord?> getRecordById(int id) {
    return _databaseHelper.getHealthRecordById(id);
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dine_in_table.dart';
import '../services/api/dine_in_service.dart';

class DineInProvider extends ChangeNotifier {
  static const String _tablePrefKey = 'le_frais_dine_in_table';

  final DineInService dineInService;

  DineInTable? _currentTable;
  bool _isLoading = false;
  String? _error;

  DineInProvider({required this.dineInService}) {
    _loadSavedTable();
  }

  DineInTable? get currentTable => _currentTable;
  bool get hasTable => _currentTable != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> validateAndSetTable(String scannedValue) async {
    final token = extractToken(scannedValue);
    if (token == null || token.isEmpty) {
      _error = 'This QR code is not a valid Le Frais table code.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final table = await dineInService.validateTableToken(token);
      _currentTable = table;
      await _saveTable(table);
      _error = null;
      return true;
    } on DineInException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to validate this table. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? extractToken(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final queryToken = uri.queryParameters['token'];
      if (queryToken != null && queryToken.trim().isNotEmpty) {
        return queryToken.trim();
      }

      if (uri.scheme == 'myrestaurant' || uri.scheme == 'lefraiscafe') {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) return segments.last.trim();
        if (uri.host.isNotEmpty) return uri.host.trim();
      }
    }

    if (!raw.contains(' ') && raw.length >= 16) {
      return raw;
    }
    return null;
  }

  Future<void> clearTable() async {
    _currentTable = null;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tablePrefKey);
    notifyListeners();
  }

  Future<void> _saveTable(DineInTable table) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tablePrefKey, jsonEncode(table.toJson()));
  }

  Future<void> _loadSavedTable() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tablePrefKey);
    if (saved == null) return;

    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      _currentTable = DineInTable.fromJson(data);
      notifyListeners();
    } catch (_) {
      await prefs.remove(_tablePrefKey);
    }
  }
}

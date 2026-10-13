import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roll_card.dart';

class CatalogueService {
  static const String _customCardsKey = 'user_custom_cards';
  
  List<RollCard> _cachedCards = [];
  bool _isLoaded = false;

  Future<List<RollCard>> getCards({bool forceRefresh = false}) async {
    if (_isLoaded && !forceRefresh && _cachedCards.isNotEmpty) {
      return _cachedCards;
    }

    final List<RollCard> combined = [];

    // 1. Load default seed from cards.json
    try {
      final jsonString = await rootBundle.loadString('assets/cards.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            combined.add(RollCard.fromJson(item, isUserCreated: false));
          }
        }
      }
    } catch (e) {
      // Fallback if cards.json is not yet available or failing
    }

    // 2. Load custom user cards from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_customCardsKey);
      if (customJson != null && customJson.isNotEmpty) {
        final dynamic decoded = jsonDecode(customJson);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              combined.insert(0, RollCard.fromJson(item, isUserCreated: true));
            }
          }
        }
      }
    } catch (_) {}

    _cachedCards = combined;
    _isLoaded = true;
    return combined;
  }

  Future<void> saveCustomCard(RollCard newCard) async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString(_customCardsKey);
    List<dynamic> list = [];
    if (customJson != null && customJson.isNotEmpty) {
      try {
        list = jsonDecode(customJson) as List<dynamic>;
      } catch (_) {
        list = [];
      }
    }

    // Remove existing if same code
    list.removeWhere((item) => (item as Map<String, dynamic>)['code'] == newCard.code);
    list.insert(0, newCard.toJson());

    await prefs.setString(_customCardsKey, jsonEncode(list));
    await getCards(forceRefresh: true);
  }

  Future<void> deleteCard(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString(_customCardsKey);
    if (customJson != null && customJson.isNotEmpty) {
      try {
        final list = (jsonDecode(customJson) as List<dynamic>)
            .where((item) => (item as Map<String, dynamic>)['code'] != code)
            .toList();
        await prefs.setString(_customCardsKey, jsonEncode(list));
      } catch (_) {}
    }
    await getCards(forceRefresh: true);
  }
}

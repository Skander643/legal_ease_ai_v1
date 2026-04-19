import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_item.dart';

class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  HistoryNotifier() : super([]) {
    loadHistory();
  }

  final _box = Hive.box('analysis_box');

  void loadHistory() {
    final List<HistoryItem> items = _box.values.map((item) {
      // Hive stores data as Map<dynamic, dynamic>, we convert it
      return HistoryItem.fromMap(item as Map<dynamic, dynamic>);
    }).toList();
    
    // Sort by date descending (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));
    state = items;
  }

  Future<void> addHistory(HistoryItem item) async {
    await _box.put(item.id, item.toMap());
    loadHistory(); // Refresh state
  }

  Future<void> deleteHistory(String id) async {
    await _box.delete(id);
    loadHistory(); // Refresh state
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryItem>>((ref) {
  return HistoryNotifier();
});
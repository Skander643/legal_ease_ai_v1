import 'package:uuid/uuid.dart';

class HistoryItem {
  final String id;
  final String title;
  final DateTime date;
  final String pdfPath;
  final String summary;
  final List<String> keyClauses;
  final List<String> risks;

  HistoryItem({
    String? id,
    required this.title,
    required this.date,
    required this.pdfPath,
    required this.summary,
    required this.keyClauses,
    required this.risks,
  }) : id = id ?? const Uuid().v4();

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'pdfPath': pdfPath,
      'summary': summary,
      'keyClauses': keyClauses,
      'risks': risks,
    };
  }

  // Create from Map (when reading from Hive)
  factory HistoryItem.fromMap(Map<dynamic, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      pdfPath: map['pdfPath'],
      summary: map['summary'],
      keyClauses: List<String>.from(map['keyClauses']),
      risks: List<String>.from(map['risks']),
    );
  }
}
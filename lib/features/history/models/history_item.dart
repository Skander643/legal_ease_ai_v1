import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HistoryItem {
  final String id;
  final String pdfFileName; 
  final String summary; 
  final DateTime date;

  HistoryItem({
    String? id,
    required this.pdfFileName,
    required this.summary,
    required this.date,
  }) : id = id ?? const Uuid().v4();


  /// Convertit l'HistoryItem en Map pour Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pdfFileName': pdfFileName,
      'summary': summary,
      'date': date,
    };
  }


  /// Crée un HistoryItem à partir d'un document Firestore.
  factory HistoryItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryItem(
      id: data['id'] ?? doc.id,
      pdfFileName: data['pdfFileName'] ?? 'Contrat',
      summary: data['summary'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

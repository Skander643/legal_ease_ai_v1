import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// HistoryItem
///
/// Représente une analyse sauvegardée dans Firestore.
///
/// Propriétés:
/// - id: Identifiant unique (généré automatiquement)
/// - pdfFileName: Nom du fichier PDF analysé
/// - summary: Résumé généré par l'IA
/// - date: Timestamp de création
/// - keyClauses: Clauses importantes extraites
/// - risks: Risques identifiés
class HistoryItem {
  final String id;
  final String pdfFileName; // Nom du fichier PDF
  final String summary; // Résumé de l'analyse
  final DateTime date; // Timestamp de création

  HistoryItem({
    String? id,
    required this.pdfFileName,
    required this.summary,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  /// toMap
  ///
  /// Convertit l'HistoryItem en Map pour Firestore.
  /// Firestore stocke les DateTime comme Timestamp automatiquement.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pdfFileName': pdfFileName,
      'summary': summary,
      'date': date,
    };
  }

  /// fromFirestore
  ///
  /// Crée un HistoryItem à partir d'un document Firestore.
  ///
  /// Paramètres:
  /// - doc: DocumentSnapshot de Firestore
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

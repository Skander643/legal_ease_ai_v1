import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history_item.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// HistoryItem Model
/// (Imported from models/history_item.dart)

/// historyProvider
///
/// Provider Riverpod exposant l'historique cloud des analyses.
///
/// ⭐ IMPORTANT: Ce provider DÉPEND de authStateProvider
/// - Quand l'utilisateur se connecte/déconnecte, le provider se recrée automatiquement
/// - Cela prévient les erreurs permission-denied lors de la permutation de compte
/// - Le stream listener est annulé proprement lors du changement d'utilisateur
///
/// Type: StreamProvider<AsyncValue<List<HistoryItem>>>
/// - État: AsyncValue pour gérer loading/error/data
/// - Stream: Écoute les changements en temps réel de Firestore
///
/// Avantages de AsyncValue:
/// - ✅ Gère loading state (afficher spinner)
/// - ✅ Gère error state (afficher message d'erreur)
/// - ✅ Gère data state (afficher les analyses)
///
/// Utilisation:
/// ```dart
/// // Regarder l'historique avec gestion des états
/// final historyAsync = ref.watch(historyProvider);
/// historyAsync.when(
///   loading: () => LoadingSpinner(),
///   error: (err, _) => ErrorWidget(err),
///   data: (items) => HistoryListWidget(items),
/// );
///
/// // Ajouter une analyse
/// await ref.read(historyProvider.notifier).addHistory(item);
///
/// // Supprimer une analyse
/// await ref.read(historyProvider.notifier).deleteHistory(id);
/// ```
final historyProvider = StreamProvider<List<HistoryItem>>((ref) {
  // Écouter les changements d'authentification
  // IMPORTANT: Ce watch() garantit que le provider se recrée quand l'utilisateur change
  final authState = ref.watch(authStateProvider);

  return authState.when(
    // Si l'authentification est en cours de chargement
    loading: () => Stream.value([]),

    // Si erreur d'authentification
    error: (err, _) => Stream.error(err),

    // Quand on a l'état d'authentification (user ou null)
    data: (user) {
      // Si pas d'utilisateur connecté
      if (user == null) {
        return Stream.value([]);
      }

      // Sinon, écouter les analyses de cet utilisateur en temps réel
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        // Convertir les documents Firestore en HistoryItems
        return snapshot.docs
            .map((doc) => HistoryItem.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        // Gérer les erreurs Firestore (permission-denied, etc)
        throw Exception('Erreur lors du chargement: $error');
      });
    },
  );
});

/// historyControllerProvider
///
/// Provider pour accéder aux fonctions addHistory et deleteHistory.
/// Utilisé pour ajouter et supprimer des analyses.
///
/// Utilisation:
/// ```dart
/// await ref.read(historyControllerProvider).addHistory(item);
/// await ref.read(historyControllerProvider).deleteHistory(itemId);
/// ```
final historyControllerProvider = Provider<HistoryController>((ref) {
  return HistoryController(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

/// HistoryController
///
/// Contrôleur pour les opérations d'ajout/suppression d'analyses.
/// Séparé du stream provider pour une meilleure séparation des responsabilités.
class HistoryController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  HistoryController({
    required this.auth,
    required this.firestore,
  });

  /// addHistory
  ///
  /// Ajoute une nouvelle analyse à Firestore.
  /// Les données sont stockées sous la collection privée de l'utilisateur.
  ///
  /// Paramètres:
  /// - item: L'HistoryItem à ajouter
  Future<void> addHistory(HistoryItem item) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Ajouter à la sous-collection 'analyses' de l'utilisateur
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(item.id)
          .set(item.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }

  /// deleteHistory
  ///
  /// Supprime une analyse de Firestore.
  /// Seul le propriétaire peut supprimer ses propres analyses.
  ///
  /// Paramètres:
  /// - id: L'ID de l'HistoryItem à supprimer
  Future<void> deleteHistory(String id) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Supprimer de la sous-collection
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}

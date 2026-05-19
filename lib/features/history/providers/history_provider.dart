import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/history_item.dart';
import '../../../features/auth/providers/auth_provider.dart';

final historyProvider = StreamProvider<List<HistoryItem>>((ref) {
  // Écouter les changements d'authentification
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


final historyControllerProvider = Provider<HistoryController>((ref) {
  return HistoryController(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class HistoryController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  HistoryController({
    required this.auth,
    required this.firestore,
  });


  /// Ajoute une nouvelle analyse à Firestore.
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


  /// Supprime une analyse de Firestore.
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

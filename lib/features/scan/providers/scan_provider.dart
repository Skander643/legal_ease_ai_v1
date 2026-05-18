import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// ScanState
///
/// Classe immutable représentant l'état du scanner PDF.
/// Utilise le pattern Immutable pour garantir la réactivité avec Riverpod.
///
/// Propriétés:
/// - selectedFile: Le fichier PDF sélectionné (null si aucun)
/// - extractedText: Texte extrait du PDF (vide par défaut)
/// - isLoading: Flag de chargement (lors de l'extraction)
/// - error: Message d'erreur (null si pas d'erreur)
class ScanState {
  final File? selectedFile;
  final String extractedText;
  final bool isLoading;
  final String? error;

  ScanState({
    this.selectedFile,
    this.extractedText = '',
    this.isLoading = false,
    this.error,
  });

  /// copyWith
  ///
  /// Crée une nouvelle instance de ScanState avec les valeurs modifiées.
  /// Permet une mise à jour immutable de l'état.
  ///
  /// Exemple:
  /// ```dart
  /// final newState = state.copyWith(isLoading: true);
  /// ```
  ScanState copyWith({
    File? selectedFile,
    String? extractedText,
    bool? isLoading,
    String? error,
  }) {
    return ScanState(
      selectedFile: selectedFile ?? this.selectedFile,
      extractedText: extractedText ?? this.extractedText,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow error to be null explicitly
    );
  }
}

/// ScanNotifier
///
/// Gère la logique de sélection et d'extraction de fichiers PDF.
///
/// Processus complet:
/// 1. Ouvrir le sélecteur de fichiers (FilePicker)
/// 2. Valider le fichier (format, taille)
/// 3. Copier le fichier dans le stockage local de l'app
/// 4. Extraire le texte avec Syncfusion
/// 5. Mettre à jour l'état Riverpod
///
/// Gestion d'erreurs:
/// - Fichier annulé: Retour sans changement
/// - Erreur d'extraction: Message d'erreur affiché
/// - Pas de droits d'accès: Exception capturée
class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(ScanState());

  /// pickAndProcessPdf
  ///
  /// Flux complet de sélection et traitement d'un PDF:
  ///
  /// 1. Lance le FilePicker (utilisateur sélectionne un PDF)
  /// 2. Valide la sélection (non-null)
  /// 3. Copie le fichier dans getApplicationDocumentsDirectory()
  ///    (persistance offline + isolation du sandbox)
  /// 4. Utilise Syncfusion pour extraire le texte
  /// 5. Met à jour l'état avec le fichier et le texte
  ///
  /// Erreurs gérées:
  /// - Utilisateur annule: Retour silencieux
  /// - Impossible de lire le fichier: Exception capturée
  /// - Extraction échouée: Message d'erreur affiché
  Future<void> pickAndProcessPdf() async {
    try {
      // Marquer l'état comme "en cours de chargement"
      state = state.copyWith(isLoading: true, error: null);

      // 1. Ouvrir le FilePicker pour sélectionner un PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        // Utilisateur a annulé le picker
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2. Récupérer le fichier sélectionné
      File pickedFile = File(result.files.single.path!);

      // 3. Copier le fichier dans le répertoire local de l'app
      // Raison: Permettre l'accès hors-ligne et la persistance
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/${result.files.single.name}';
      final savedFile = await pickedFile.copy(localPath);

      // 4. Extraire le texte avec Syncfusion
      // Note: Syncfusion est plus robuste que d'autres solutions
      final PdfDocument document =
          PdfDocument(inputBytes: await savedFile.readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      document.dispose(); // Libérer les ressources

      // 5. Mettre à jour l'état avec succès
      state = state.copyWith(
        selectedFile: savedFile,
        extractedText: text,
        isLoading: false,
      );
    } catch (e) {
      // En cas d'erreur, capturer et afficher le message
      state = state.copyWith(
        isLoading: false,
        error: "Erreur lors du traitement du PDF : ${e.toString()}",
      );
    }
  }

  /// clearSelection
  ///
  /// Réinitialise l'état du scanner.
  /// Utile après une analyse réussie ou un changement d'écran.
  void clearSelection() {
    state = ScanState();
  }
}

/// scanProvider
///
/// Provider Riverpod exposant le ScanNotifier.
/// Permet à tous les widgets d'accéder à l'état du scanner.
///
/// Utilisation:
/// ```dart
/// // Regarder l'état
/// final scanState = ref.watch(scanProvider);
///
/// // Exécuter une action
/// await ref.read(scanProvider.notifier).pickAndProcessPdf();
/// ```
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier();
});

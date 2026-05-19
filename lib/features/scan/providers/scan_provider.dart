import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
      error: error,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(ScanState());

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


  void clearSelection() {
    state = ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier();
});

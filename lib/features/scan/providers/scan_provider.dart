import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// State class to hold our PDF data
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
      error: error, // Allow error to be null
    );
  }
}

// The Notifier to manage the PDF picking and extraction logic
class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier() : super(ScanState());

  Future<void> pickAndProcessPdf() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Pick the PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        state = state.copyWith(isLoading: false);
        return; // User canceled the picker
      }

      File pickedFile = File(result.files.single.path!);

      // 2. Save it locally (getApplicationDocumentsDirectory as per specs)
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/${result.files.single.name}';
      final savedFile = await pickedFile.copy(localPath);

      // 3. Extract text using Syncfusion
      final PdfDocument document = PdfDocument(inputBytes: await savedFile.readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      // 4. Update state with the saved file and extracted text
      state = state.copyWith(
        selectedFile: savedFile,
        extractedText: text,
        isLoading: false,
      );

    } catch (e) {
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

// Expose the provider
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier();
});
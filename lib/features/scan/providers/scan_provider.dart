import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:legal_ease_ai/core/providers/locale_provider.dart';

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
  ScanNotifier(this._ref) : super(ScanState());

  final Ref _ref;

  AppLocalizations get _l10n =>
      lookupAppLocalizations(_ref.read(localeProvider));

  Future<void> pickAndProcessPdf() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      File pickedFile = File(result.files.single.path!);

      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/${result.files.single.name}';
      final savedFile = await pickedFile.copy(localPath);

      final PdfDocument document =
          PdfDocument(inputBytes: await savedFile.readAsBytes());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      state = state.copyWith(
        selectedFile: savedFile,
        extractedText: text,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _l10n.errorPdfProcessing(e.toString()),
      );
    }
  }

  void clearSelection() {
    state = ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref);
});

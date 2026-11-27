import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;

typedef OcrProgress = void Function(int current, int total, String message);

class OcrPageSelection {
  const OcrPageSelection._(this.pages);

  final List<int> pages;

  factory OcrPageSelection.all(int pageCount) {
    if (pageCount <= 0) return const OcrPageSelection._([]);
    return OcrPageSelection._(
        List<int>.generate(pageCount, (index) => index + 1));
  }

  /// Parses 1-based page numbers and ranges such as `1-3, 6`.
  static OcrPageSelection parse(String value, int pageCount) {
    final selected = <int>{};
    for (final part in value.split(',')) {
      final token = part.trim();
      if (token.isEmpty) continue;
      final range = token.split('-').map((item) => int.tryParse(item.trim()));
      final values = range.toList();
      if (values.length == 1 && values.first != null) {
        selected.add(values.first!);
      } else if (values.length == 2 && values.every((item) => item != null)) {
        final start = values[0]!;
        final end = values[1]!;
        for (var page = start; page <= end; page++) {
          selected.add(page);
        }
      }
    }
    final valid = selected.where((page) => page >= 1 && page <= pageCount);
    final pages = valid.toList()..sort();
    return OcrPageSelection._(pages);
  }
}

class OcrPageResult {
  const OcrPageResult({required this.page, required this.text});

  final int page;
  final String text;

  Map<String, dynamic> toJson() => {'page': page, 'text': text};
}

class OcrDocumentResult {
  const OcrDocumentResult({required this.pages, required this.source});

  final List<OcrPageResult> pages;
  final String source;

  String get text => pages
      .map((page) => 'Página ${page.page}\n${page.text.trim()}'.trim())
      .join('\n\n');

  Map<String, dynamic> toJson() => {
        'source': source,
        'pages': pages.map((page) => page.toJson()).toList(),
      };
}

class OcrService {
  static const _maxPdfBytes = 50 * 1024 * 1024;

  Future<OcrDocumentResult> recognizeImage(String path,
      {OcrProgress? onProgress}) async {
    final file = File(path);
    if (!await file.exists() || await file.length() == 0) {
      throw const FormatException('Imagem inexistente ou vazia.');
    }
    onProgress?.call(0, 1, 'Lendo imagem...');
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result =
          await recognizer.processImage(InputImage.fromFilePath(path));
      if (result.text.trim().isEmpty) {
        throw const FormatException('Nenhum texto foi reconhecido na imagem.');
      }
      onProgress?.call(1, 1, 'OCR concluído.');
      return OcrDocumentResult(
          source: 'imagem', pages: [OcrPageResult(page: 1, text: result.text)]);
    } finally {
      await recognizer.close();
    }
  }

  Future<int> pdfPageCount(String path) async {
    await _validatePdfFile(File(path));
    final document = await pdfx.PdfDocument.openFile(path);
    try {
      return document.pagesCount;
    } finally {
      await document.close();
    }
  }

  Future<OcrDocumentResult> recognizePdf(String path,
      {OcrPageSelection? selection, OcrProgress? onProgress}) async {
    final file = File(path);
    await _validatePdfFile(file);
    final int pageCount;
    try {
      pageCount = await pdfPageCount(path);
    } catch (error) {
      if (error is FormatException) rethrow;
      throw const FormatException(
          'PDF inválido, protegido por senha ou ilegível.');
    }
    final pages = selection ?? OcrPageSelection.all(pageCount);
    if (pages.pages.isEmpty) {
      throw const FormatException('Nenhuma página válida foi selecionada.');
    }

    final OcrDocumentResult selectable;
    try {
      selectable = await _extractSelectableText(file, pages.pages);
    } catch (error) {
      if (error is FormatException) rethrow;
      throw const FormatException(
          'PDF inválido, protegido por senha ou ilegível.');
    }
    final hasScannedPages =
        selectable.pages.any((page) => page.text.trim().isEmpty);
    if (!hasScannedPages) {
      onProgress?.call(
          pages.pages.length, pages.pages.length, 'Texto do PDF extraído.');
      return selectable;
    }

    pdfx.PdfDocument? document;
    TextRecognizer? recognizer;
    final results = <OcrPageResult>[];
    Directory? temporaryDirectory;
    try {
      document = await pdfx.PdfDocument.openFile(path);
      temporaryDirectory = await getTemporaryDirectory();
      for (var index = 0; index < pages.pages.length; index++) {
        final pageNumber = pages.pages[index];
        final extracted = selectable.pages[index];
        if (extracted.text.trim().isNotEmpty) {
          results.add(extracted);
          onProgress?.call(index + 1, pages.pages.length,
              'Texto da página $pageNumber extraído.');
          continue;
        }
        onProgress?.call(index, pages.pages.length,
            'Processando página $pageNumber de ${pages.pages.length}...');
        final page = await document.getPage(pageNumber);
        pdfx.PdfPageImage? rendered;
        try {
          rendered = await page.render(
              width: page.width.clamp(900, 1600).toDouble(),
              height: page.height.clamp(900, 2200).toDouble(),
              format: pdfx.PdfPageImageFormat.png);
        } finally {
          await page.close();
        }
        if (rendered == null || rendered.bytes.isEmpty) {
          results.add(OcrPageResult(page: pageNumber, text: ''));
          onProgress?.call(index + 1, pages.pages.length,
              'Página $pageNumber sem imagem renderizável.');
          continue;
        }
        final temporaryFile = File(
            '${temporaryDirectory.path}${Platform.pathSeparator}travia_ocr_${DateTime.now().microsecondsSinceEpoch}.png');
        await temporaryFile.writeAsBytes(rendered.bytes, flush: true);
        try {
          recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
          final recognized = await recognizer
              .processImage(InputImage.fromFilePath(temporaryFile.path));
          results.add(OcrPageResult(page: pageNumber, text: recognized.text));
        } finally {
          await temporaryFile.delete().catchError((_) => temporaryFile);
        }
        onProgress?.call(
            index + 1, pages.pages.length, 'Página $pageNumber processada.');
      }
      onProgress?.call(
          pages.pages.length, pages.pages.length, 'OCR concluído.');
      final hasSelectablePages =
          selectable.pages.any((page) => page.text.trim().isNotEmpty);
      final hasRecognizedText =
          results.any((page) => page.text.trim().isNotEmpty);
      if (!hasRecognizedText) {
        throw const FormatException(
            'Nenhum texto foi reconhecido nas páginas selecionadas.');
      }
      return OcrDocumentResult(
          source: hasSelectablePages ? 'pdf-misto' : 'pdf-escaneado',
          pages: results);
    } finally {
      await recognizer?.close();
      await document?.close();
    }
  }

  Future<OcrDocumentResult> _extractSelectableText(
      File file, List<int> selectedPages) async {
    final document =
        syncfusion.PdfDocument(inputBytes: await file.readAsBytes());
    try {
      final extractor = syncfusion.PdfTextExtractor(document);
      final pages = selectedPages
          .map((page) => OcrPageResult(
              page: page,
              text: extractor.extractText(
                  startPageIndex: page - 1, endPageIndex: page - 1)))
          .toList();
      return OcrDocumentResult(source: 'pdf-texto', pages: pages);
    } finally {
      document.dispose();
    }
  }

  Future<void> _validatePdfFile(File file) async {
    if (!await file.exists() || await file.length() == 0) {
      throw const FormatException('PDF inexistente ou vazio.');
    }
    if (await file.length() > _maxPdfBytes) {
      throw const FormatException(
          'PDF maior que 50 MB. Selecione um arquivo menor ou divida o documento.');
    }
    final handle = await file.open();
    try {
      final header = await handle.read(5);
      const expected = [37, 80, 68, 70, 45];
      if (header.length != expected.length ||
          !List<int>.generate(header.length, (index) => header[index])
              .asMap()
              .entries
              .every((entry) => entry.value == expected[entry.key])) {
        throw const FormatException(
            'O arquivo selecionado não é um PDF válido.');
      }
    } finally {
      await handle.close();
    }
  }
}

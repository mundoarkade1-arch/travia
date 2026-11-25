import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:travia/core/ocr_service.dart';

void main() {
  test('interpreta páginas individuais e intervalos sem duplicar páginas', () {
    final result = OcrPageSelection.parse('3, 1-2, 2, 99', 4);
    expect(result.pages, [1, 2, 3]);
  });

  test('ignora seleção de páginas inválida', () {
    final result = OcrPageSelection.parse('abc, 0, 8-9', 4);
    expect(result.pages, isEmpty);
  });

  test('serializa texto por página para persistência local', () {
    const result = OcrDocumentResult(
        source: 'imagem', pages: [OcrPageResult(page: 1, text: 'Engenharia')]);
    expect(result.text, contains('Página 1'));
    expect(result.toJson()['pages'], hasLength(1));
  });

  test('recusa imagem inexistente ou vazia', () async {
    final service = OcrService();
    expect(service.recognizeImage('arquivo-que-nao-existe.png'),
        throwsA(isA<FormatException>()));
    final file = File('${Directory.systemTemp.path}/travia-empty-ocr.png');
    await file.writeAsBytes([]);
    addTearDown(() => file.delete().catchError((_) => file));
    expect(service.recognizeImage(file.path), throwsA(isA<FormatException>()));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:travia/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(const TraviaApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsOneWidget);
  }

  Future<void> tapNavigation(WidgetTester tester, String label) async {
    final destination = find.text(label).last;
    expect(destination, findsOneWidget);
    await tester.tap(destination);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  testWidgets('inicializa e exibe a matriz completa', (tester) async {
    await openApp(tester);
    await tapNavigation(tester, 'Graduação');

    expect(find.byType(Card), findsNWidgets(70));
    expect(find.text('Administração e Empreendedorismo'), findsOneWidget);
  });

  testWidgets('altera situação acadêmica pela interface real', (tester) async {
    await openApp(tester);
    await tapNavigation(tester, 'Graduação');

    final status = find.byType(DropdownButton<String>).first;
    await tester.tap(status);
    await tester.pumpAndSettle();
    expect(find.text('Em andamento'), findsWidgets);
    await tester.tap(find.text('Em andamento').last);
    await tester.pumpAndSettle();
    expect(find.text('Em andamento'), findsWidgets);
  });

  testWidgets('registra nota e anotação pela interface real', (tester) async {
    await openApp(tester);
    await tapNavigation(tester, 'Graduação');
    await tester.tap(find.text('Administração e Empreendedorismo').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Nota:'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '8.5');
    await tester.tap(find.text('Salvar').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Nota 8.5'), findsOneWidget);

    await tapNavigation(tester, 'Caderno');
    final note = find.byType(TextField).first;
    await tester.tap(note);
    await tester.enterText(note, 'integração_android_anotação');
    await tester.tap(find.text('Salvar caderno'));
    await tester.pumpAndSettle();
    expect(find.text('Caderno salvo.'), findsOneWidget);
  });

  testWidgets('cria evento e tarefa, conclui tarefa e inicia timer',
      (tester) async {
    await openApp(tester);
    await tapNavigation(tester, 'Calendário');
    await tester.tap(find.text('Adicionar evento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'evento_integration');
    await tester.tap(find.text('Salvar').last);
    await tester.pumpAndSettle();
    expect(find.text('evento_integration'), findsOneWidget);

    await tester.tap(find.text('Início').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estudar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'tarefa_integration');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('tarefa_integration'), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile).last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Iniciar 25 minutos'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Pausar'), findsOneWidget);
  });

  testWidgets('abre simuladores e configurações', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laboratório'));
    await tester.pumpAndSettle();
    expect(find.text('Laboratório'), findsWidgets);
    expect(find.text('Abrir'), findsWidgets);

    await tester.tap(find.text('Abrir').first);
    await tester.pumpAndSettle();
    expect(find.text('Calcular'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    expect(find.text('Servidor'), findsOneWidget);
    expect(find.text('Receber dados'), findsOneWidget);
  });
}

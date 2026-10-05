import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grao/data/mock_repository.dart';
import 'package:grao/main.dart';
import 'package:grao/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _boot(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final state = AppState(repository: MockRepository(), prefs: sp);

  // Tela alta, para não precisar rolar nos testes.
  tester.view.physicalSize = const Size(1080, 3400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(GraoApp(state: state));
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pumpAndSettle();
  return state;
}

void main() {
  testWidgets('primeira abertura passa pelo onboarding e chega no início',
      (tester) async {
    await _boot(tester);

    expect(find.text('Oi, eu sou o Grão.'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Anotar leva uns 10 segundos.'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Como você quer ser chamado?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Sofia');
    await tester.tap(find.text('Bora começar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sofia'), findsWidgets);
    expect(find.text('Sobra do mês'), findsOneWidget);
  });

  testWidgets('navega entre as quatro abas', (tester) async {
    await _boot(tester, prefs: {'onboarded': true, 'user_name': 'Sofia'});

    final nav = find.byType(NavigationBar);
    expect(find.text('Sobra do mês'), findsOneWidget);

    await tester.tap(find.descendant(of: nav, matching: find.text('Histórico')));
    await tester.pumpAndSettle();
    expect(find.text('Tudo que entrou e saiu'), findsOneWidget);

    await tester.tap(find.descendant(of: nav, matching: find.text('Metas')));
    await tester.pumpAndSettle();
    expect(find.text('Sem meta'), findsOneWidget);

    await tester.tap(find.descendant(of: nav, matching: find.text('Eu')));
    await tester.pumpAndSettle();
    expect(find.text('Modo demonstração'), findsOneWidget);
  });

  testWidgets('anota um gasto novo e ele entra na lista', (tester) async {
    final state =
        await _boot(tester, prefs: {'onboarded': true, 'user_name': 'Sofia'});
    final before = state.transactions.length;

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Anotar'));
    await tester.pumpAndSettle();
    expect(find.text('Nova anotação'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.tap(find.text('0'));
    await tester.pump();
    expect(find.text('R\$ 50'), findsOneWidget);

    await tester.tap(find.text('Salvar anotação'));
    await tester.pumpAndSettle();

    expect(state.transactions.length, before + 1);
    expect(find.text('Gasto anotado.'), findsOneWidget);
  });

  testWidgets('não deixa salvar com valor zerado', (tester) async {
    final state =
        await _boot(tester, prefs: {'onboarded': true, 'user_name': 'Sofia'});
    final before = state.transactions.length;

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Anotar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar anotação'));
    await tester.pump();

    expect(find.text('Coloca um valor primeiro.'), findsOneWidget);
    expect(state.transactions.length, before);
  });
}

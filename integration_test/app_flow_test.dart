import 'package:fluxo_financeiro/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fluxo principal completo', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponível'), findsOneWidget);

    await tester.tap(find.text('Extrato'));
    await tester.pumpAndSettle();
    expect(find.text('Compra no mercado'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'mercado');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compra no mercado'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes da transação'), findsOneWidget);
    expect(find.text('tx_005'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.copy_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Identificador copiado.'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'mercado',
    );
  });
}

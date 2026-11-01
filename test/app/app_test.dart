import 'package:fluxo_financeiro/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inicia o scaffold do aplicativo', (tester) async {
    await tester.pumpWidget(const FluxoFinanceiroApp());

    expect(find.text('Fluxo Financeiro'), findsOneWidget);
  });
}

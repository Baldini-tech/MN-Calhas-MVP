import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mn_calhas/main.dart';

void main() {
  testWidgets('Verifica a tela inicial do MN Calhas', (tester) async {
    await tester.pumpWidget(const MNCalhasApp());

    // Verifica o nome do aplicativo
    expect(find.text('MN Calhas'), findsOneWidget);

    // Verifica os botões principais
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Orçamentos'), findsOneWidget);
    expect(find.text('Serviços'), findsOneWidget);

    // Rola a página até encontrar o botão Sair
    await tester.scrollUntilVisible(
      find.text('Sair'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    // Verifica o botão Sair
    expect(find.text('Sair'), findsOneWidget);
  });
}
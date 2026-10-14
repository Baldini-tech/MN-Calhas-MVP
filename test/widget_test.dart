import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mn_calhas/main.dart';
import 'package:mn_calhas/screens/clientes_screen.dart';

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
    testWidgets('Verifica a navegacao para a tela de Clientes', (tester) async {
    await tester.pumpWidget(const MNCalhasApp());

    // Localiza o botao Clientes na tela inicial.
    expect(find.text('Clientes'), findsOneWidget);

    // Abre a tela de gerenciamento de clientes.
    await tester.tap(find.text('Clientes'));

// Aguarda a transição de navegação.
await tester.pump();
await tester.pump(const Duration(milliseconds: 500));

    // Confirma que a tela inicial nao esta mais visivel.
    expect(
      find.text('Organização e mais resultados para a sua empresa.'),
      findsNothing,
    );

    // Confirma que existe uma tela de destino.
    expect(find.byType(ClientesScreen), findsOneWidget);
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mn_calhas/main.dart';
import 'package:mn_calhas/screens/clientes_screen.dart';
import 'package:mn_calhas/screens/orcamentos_screen.dart';
import 'package:mn_calhas/screens/servicos_screen.dart';

void main() {
  testWidgets('Verifica a tela inicial do MN Calhas', (tester) async {
    await tester.pumpWidget(const MNCalhasApp());

    // Verifica o nome do aplicativo
    expect(find.text('MN Calhas'), findsOneWidget);

    // Verifica os botões principais
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Orçamentos'), findsOneWidget);

    // Rola a tela até encontrar o botão Serviços
    await tester.scrollUntilVisible(
      find.text('Serviços'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

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

  testWidgets('Verifica a navegacao para a tela de Orcamentos', (tester) async {
    await tester.pumpWidget(const MNCalhasApp());

    // Verifica se a opcao Orcamentos aparece na tela inicial.
    expect(find.text('Orçamentos'), findsOneWidget);

    // Abre a tela de orcamentos.
    await tester.tap(find.text('Orçamentos'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verifica se a tela de orcamentos foi aberta.
    expect(find.byType(OrcamentosScreen), findsOneWidget);
  });

  testWidgets('Verifica a navegacao para a tela de Servicos', (tester) async {
    await tester.pumpWidget(const MNCalhasApp());

    // Rola a página até encontrar o botão Serviços.
    await tester.scrollUntilVisible(
      find.text('Serviços'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    // Verifica se o botão Serviços existe.
    expect(find.text('Serviços'), findsOneWidget);

    // Abre a tela de Servicos.
    await tester.tap(find.text('Serviços'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Confirma que a tela de Servicos foi aberta.
    expect(find.byType(ServicosScreen), findsOneWidget);
  });
}

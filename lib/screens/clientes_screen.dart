import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const azulMN = Color(0xFF103B66);
const azulBotao = Color(0xFF1768CF);
const azulEscuro = Color(0xFF071D49);

class MascaraTelefone extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) {
    String numeros = novo.text.replaceAll(RegExp(r'\D'), '');

    if (numeros.length > 11) {
      numeros = numeros.substring(0, 11);
    }

    String telefone = '';

    if (numeros.isNotEmpty) {
      final tamanhoDDD = numeros.length < 2 ? numeros.length : 2;
      telefone = '(${numeros.substring(0, tamanhoDDD)}';
    }

    if (numeros.length >= 3) {
      telefone += ') ';

      if (numeros.length <= 6) {
        telefone += numeros.substring(2);
      } else if (numeros.length <= 10) {
        telefone +=
            '${numeros.substring(2, 6)}-${numeros.substring(6)}';
      } else {
        telefone +=
            '${numeros.substring(2, 7)}-${numeros.substring(7)}';
      }
    }

    return TextEditingValue(
      text: telefone,
      selection: TextSelection.collapsed(offset: telefone.length),
    );
  }
}

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final List<Map<String, String>> clientes = [];
  final pesquisaController = TextEditingController();

  bool mostrarSucesso = false;
  bool carregando = true;
  String mensagemSucesso = '';

  @override
  void initState() {
    super.initState();
    carregarClientes();

    pesquisaController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Future<void> carregarClientes() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('clientes');

    if (!mounted) return;

    setState(() {
      if (dados != null) {
        final lista = jsonDecode(dados) as List;

        clientes
          ..clear()
          ..addAll(
            lista.map(
              (item) => Map<String, String>.from(item as Map),
            ),
          );
      }

      carregando = false;
    });
  }

  Future<void> salvarClientes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'clientes',
      jsonEncode(clientes),
    );
  }

  Future<void> abrirFormulario({int? index}) async {
    final resultado = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioClienteScreen(
          cliente: index == null
              ? null
              : Map<String, String>.from(clientes[index]),
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() {
      if (index == null) {
        clientes.add(resultado);
        mensagemSucesso = 'Cliente cadastrado com sucesso!';
      } else {
        clientes[index] = resultado;
        mensagemSucesso = 'Cliente atualizado com sucesso!';
      }

      mostrarSucesso = true;
    });

    await salvarClientes();
  }

  Future<void> excluirCliente(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: const Text(
          'Tem certeza que deseja excluir este cliente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      clientes.removeAt(index);
      mostrarSucesso = false;
    });

    await salvarClientes();
  }

  List<int> get clientesFiltrados {
    final pesquisa = pesquisaController.text.trim().toLowerCase();

    return List.generate(clientes.length, (index) => index)
        .where((index) {
      final cliente = clientes[index];

      final nome = (cliente['nome'] ?? '').toLowerCase();
      final telefone = (cliente['telefone'] ?? '').toLowerCase();

      return nome.contains(pesquisa) ||
          telefone.contains(pesquisa);
    }).toList();
  }

  Widget cardCliente(int index) {
    final cliente = clientes[index];

    final nome = cliente['nome'] ?? '';
    final telefone = cliente['telefone'] ?? '';
    final endereco = cliente['endereco'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFD9E2EF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: azulMN,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: azulEscuro,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 19,
                      color: azulMN,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        telefone.isEmpty
                            ? 'Telefone não informado'
                            : telefone,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 19,
                      color: azulMN,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        endereco.isEmpty
                            ? 'Endereço não informado'
                            : endereco,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: azulMN,
            ),
            onSelected: (opcao) {
              if (opcao == 'editar') {
                abrirFormulario(index: index);
              } else if (opcao == 'excluir') {
                excluirCliente(index);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'editar',
                child: Text('Editar'),
              ),
              PopupMenuItem(
                value: 'excluir',
                child: Text('Excluir'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = clientesFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF103B66),
                    Color(0xFF174B7D),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 58,
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MN Calhas',
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Gestão de Clientes',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (mostrarSucesso) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F7E7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFA6DEA8),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF238A3B),
                                size: 38,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  mensagemSucesso,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF125B29),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                      const Row(
                        children: [
                          Icon(
                            Icons.people_alt,
                            size: 40,
                            color: azulMN,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Clientes cadastrados',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: azulEscuro,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 55,
                          top: 4,
                          bottom: 24,
                        ),
                        child: Text(
                          'Consulte e gerencie os clientes da sua empresa.',
                          style: TextStyle(
                            color: Color(0xFF405577),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextField(
                        controller: pesquisaController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar por nome ou telefone',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: azulMN,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFD9E2EF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (carregando)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (filtrados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 35),
                          child: Center(
                            child: Text(
                              'Nenhum cliente encontrado.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      else
                        ...filtrados.map(cardCliente),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Voltar ao Menu'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: azulMN,
                                side: const BorderSide(color: azulBotao),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => abrirFormulario(),
                              icon: const Icon(Icons.add),
                              label: const Text('Novo Cliente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: azulBotao,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormularioClienteScreen extends StatefulWidget {
  final Map<String, String>? cliente;

  const FormularioClienteScreen({
    super.key,
    this.cliente,
  });

  @override
  State<FormularioClienteScreen> createState() =>
      _FormularioClienteScreenState();
}

class _FormularioClienteScreenState
    extends State<FormularioClienteScreen> {
  final formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final cliente = widget.cliente;

    if (cliente != null) {
      nomeController.text = cliente['nome'] ?? '';
      telefoneController.text = cliente['telefone'] ?? '';
      enderecoController.text = cliente['endereco'] ?? '';
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    super.dispose();
  }

  InputDecoration decoracao(String titulo, IconData icone) {
    return InputDecoration(
      hintText: titulo,
      prefixIcon: Icon(icone, color: azulMN),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFBAC8DD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: azulBotao,
          width: 2,
        ),
      ),
    );
  }

  void salvar() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cliente = <String, String>{
      'nome': nomeController.text.trim(),
      'telefone': telefoneController.text.trim(),
      'endereco': enderecoController.text.trim(),
    };

    Navigator.pop(context, cliente);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.cliente != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF103B66),
                    Color(0xFF174B7D),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 52,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MN Calhas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gestão de Clientes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0E7F0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_add_alt_1,
                                  color: azulMN,
                                  size: 48,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        editando
                                            ? 'Editar Cliente'
                                            : 'Novo Cliente',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: azulEscuro,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Preencha as informações do cliente.',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF405577),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 35),

                            const Text(
                              'Nome do cliente *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: nomeController,
                              decoration: decoracao(
                                'Digite o nome completo',
                                Icons.person_outline,
                              ),
                              validator: (valor) {
                                if (valor == null ||
                                    valor.trim().isEmpty) {
                                  return 'Informe o nome do cliente.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            const Text(
                              'Telefone',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            TextFormField(
  controller: telefoneController,
  keyboardType: TextInputType.phone,
  inputFormatters: [
  MascaraTelefone(),
],
  decoration: decoracao(
    '(00) 00000-0000',
    Icons.phone_outlined,
  ),
),

                            const SizedBox(height: 25),

                            const Text(
                              'Endereço',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: enderecoController,
                              maxLines: 2,
                              decoration: decoracao(
                                'Rua, número e bairro',
                                Icons.location_on_outlined,
                              ),
                            ),

                            const SizedBox(height: 30),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: Color(0xFF0872CF),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Os campos marcados com * são obrigatórios.',
                                      style: TextStyle(
                                        color: Color(0xFF0755A4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 35),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor:
                                          const Color(0xFFE5EAF2),
                                      foregroundColor: azulMN,
                                    ),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: salvar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: azulBotao,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                    ),
                                    icon: const Icon(Icons.save),
                                    label: const Text(
                                      'Salvar Cliente',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
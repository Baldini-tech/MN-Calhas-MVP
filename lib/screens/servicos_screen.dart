import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const azulMN = Color(0xFF103B66);
const azulBotao = Color(0xFF1768CF);

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  List<Map<String, dynamic>> servicos = [];

  String filtroSelecionado = 'Todos';
  bool mostrarSucesso = false;

  @override
  void initState() {
    super.initState();
    carregarServicos();
  }

  Future<void> carregarServicos() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('servicos');

    if (!mounted) return;

    if (dados != null) {
      setState(() {
        servicos = (jsonDecode(dados) as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      });
    }
  }

  Future<void> salvarServicos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'servicos',
      jsonEncode(servicos),
    );
  }

  Future<void> abrirFormulario({int? index}) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioServicoScreen(
          servico: index == null
              ? null
              : Map<String, dynamic>.from(servicos[index]),
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() {
      if (index == null) {
        servicos.add(resultado);
        mostrarSucesso = true;
      } else {
        servicos[index] = resultado;
        mostrarSucesso = false;
      }

      filtroSelecionado = 'Todos';
    });

    await salvarServicos();
  }

  Future<void> excluirServico(int index) async {
    setState(() {
      servicos.removeAt(index);
      mostrarSucesso = false;
    });

    await salvarServicos();
  }

  List<int> get indicesFiltrados {
    return List.generate(servicos.length, (index) => index)
        .where((index) {
      if (filtroSelecionado == 'Todos') return true;

      final status = servicos[index]['status']?.toString() ?? '';

      if (filtroSelecionado == 'Pendentes') {
        return status == 'Pendente';
      }

      if (filtroSelecionado == 'Concluídos') {
        return status == 'Concluído';
      }

      return status == 'Em andamento';
    }).toList();
  }

  Color corStatus(String status) {
    switch (status) {
      case 'Pendente':
        return const Color(0xFFFFDA62);
      case 'Em andamento':
        return const Color(0xFFB8D9FF);
      case 'Concluído':
        return const Color(0xFFB7E9B4);
      default:
        return const Color(0xFFE5EAF2);
    }
  }

  IconData iconeStatus(String status) {
    switch (status) {
      case 'Pendente':
        return Icons.access_time_filled;
      case 'Em andamento':
        return Icons.settings;
      case 'Concluído':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Widget botaoFiltro(String titulo) {
    final selecionado = filtroSelecionado == titulo;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            filtroSelecionado = titulo;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selecionado
              ? azulMN
              : const Color(0xFFEDF2F8),
          foregroundColor: selecionado
              ? Colors.white
              : azulMN,
          elevation: selecionado ? 2 : 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(titulo),
      ),
    );
  }

  Widget cardServico(int index) {
    final servico = servicos[index];

    final cliente = servico['cliente']?.toString() ?? '';
    final descricao = servico['descricao']?.toString() ?? '';
    final data = servico['data']?.toString() ?? 'Não informada';
    final status = servico['status']?.toString() ?? 'Pendente';

    final pendente = status == 'Pendente';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: pendente
            ? const Color(0xFFFFFAE8)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pendente
              ? const Color(0xFFFFD466)
              : const Color(0xFFD9E2EF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.person,
            size: 34,
            color: azulMN,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: azulMN,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF405577),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 19,
                          color: azulMN,
                        ),
                        const SizedBox(width: 7),
                        Text(data),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: corStatus(status),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            iconeStatus(status),
                            size: 20,
                            color: const Color(0xFF071D49),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF071D49),
                            ),
                          ),
                        ],
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
                excluirServico(index);
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
    final filtrados = indicesFiltrados;

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
                          'Gestão de Serviços',
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
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
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
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF238A3B),
                                size: 38,
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Serviço cadastrado com sucesso!',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF125B29),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'O novo serviço foi adicionado à lista.',
                                      style: TextStyle(
                                        color: Color(0xFF125B29),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],

                      const Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted,
                            size: 40,
                            color: azulMN,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Serviços cadastrados',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF071D49),
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
                          'Consulte e acompanhe os serviços da sua empresa.',
                          style: TextStyle(
                            color: Color(0xFF405577),
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const Text(
                        'Filtrar por status:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: azulMN,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            botaoFiltro('Todos'),
                            botaoFiltro('Pendentes'),
                            botaoFiltro('Em andamento'),
                            botaoFiltro('Concluídos'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (filtrados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 35),
                          child: Center(
                            child: Text(
                              'Nenhum serviço encontrado.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      else
                        ...filtrados.map(cardServico),

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
                                side: const BorderSide(
                                  color: azulBotao,
                                ),
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
                              label: const Text('Novo Serviço'),
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
class FormularioServicoScreen extends StatefulWidget {
  final Map<String, dynamic>? servico;

  const FormularioServicoScreen({
    super.key,
    this.servico,
  });

  @override
  State<FormularioServicoScreen> createState() =>
      _FormularioServicoScreenState();
}

class _FormularioServicoScreenState
    extends State<FormularioServicoScreen> {
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();

  List<String> clientes = [];

  String? clienteSelecionado;
  String statusSelecionado = 'Pendente';

  DateTime dataSelecionada = DateTime.now();
  bool carregando = true;

  @override
  void initState() {
    super.initState();

    final servico = widget.servico;

    if (servico != null) {
      descricaoController.text =
          servico['descricao']?.toString() ?? '';

      clienteSelecionado = servico['cliente']?.toString();

      final status = servico['status']?.toString();

      if ([
        'Pendente',
        'Em andamento',
        'Concluído',
      ].contains(status)) {
        statusSelecionado = status!;
      }

      final data = servico['data']?.toString();

      if (data != null) {
        final partes = data.split('/');

        if (partes.length == 3) {
          final dia = int.tryParse(partes[0]);
          final mes = int.tryParse(partes[1]);
          final ano = int.tryParse(partes[2]);

          if (dia != null && mes != null && ano != null) {
            final dataConvertida = DateTime(ano, mes, dia);

            if (dataConvertida.day == dia &&
                dataConvertida.month == mes &&
                dataConvertida.year == ano) {
              dataSelecionada = dataConvertida;
            }
          }
        }
      }
    }

    carregarClientes();
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> carregarClientes() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('clientes');

    final nomes = <String>[];

    if (dados != null) {
      final lista = jsonDecode(dados) as List;

      for (final item in lista) {
        final nome = item['nome']?.toString().trim() ?? '';

        if (nome.isNotEmpty && !nomes.contains(nome)) {
          nomes.add(nome);
        }
      }
    }

    // Mantém o cliente original ao editar um serviço antigo.
    if (clienteSelecionado != null &&
        !nomes.contains(clienteSelecionado)) {
      nomes.add(clienteSelecionado!);
    }

    if (!mounted) return;

    setState(() {
      clientes = nomes;

      if (clienteSelecionado == null && clientes.isNotEmpty) {
        clienteSelecionado = clientes.first;
      }

      carregando = false;
    });
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Future<void> escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null && mounted) {
      setState(() {
        dataSelecionada = data;
      });
    }
  }

  void salvar() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final servico = <String, dynamic>{
      'cliente': clienteSelecionado!,
      'descricao': descricaoController.text.trim(),
      'data': formatarData(dataSelecionada),
      'status': statusSelecionado,
    };

    // Preserva o valor de registros antigos, caso exista.
    if (widget.servico?.containsKey('valor') ?? false) {
      servico['valor'] = widget.servico!['valor'];
    }

    Navigator.pop(context, servico);
  }

  InputDecoration decoracao(String titulo) {
    return InputDecoration(
      labelText: titulo,
      labelStyle: const TextStyle(color: azulMN),
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
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.servico != null;

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
                          'Gestão de Serviços',
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
                    constraints: const BoxConstraints(
                      maxWidth: 650,
                    ),
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
                                  Icons.note_add_outlined,
                                  color: azulMN,
                                  size: 52,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        editando
                                            ? 'Editar Serviço'
                                            : 'Novo Serviço',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF071D49),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Preencha as informações do serviço.',
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
                              'Cliente *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (carregando)
                              const CircularProgressIndicator()
                            else
                              DropdownButtonFormField<String>(
                                initialValue: clienteSelecionado,
                                isExpanded: true,
                                decoration: decoracao('Selecione o cliente'),
                                items: clientes.map((nome) {
                                  return DropdownMenuItem(
                                    value: nome,
                                    child: Text(
                                      nome,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: clientes.isEmpty
                                    ? null
                                    : (valor) {
                                        setState(() {
                                          clienteSelecionado = valor;
                                        });
                                      },
                                validator: (valor) {
                                  if (valor == null) {
                                    return 'Cadastre um cliente primeiro.';
                                  }
                                  return null;
                                },
                              ),

                            const SizedBox(height: 25),

                            const Text(
                              'Descrição do serviço *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            const SizedBox(height: 10),

                            TextFormField(
                              controller: descricaoController,
                              maxLines: 3,
                              decoration: decoracao(
                                'Ex.: Instalação de calha',
                              ),
                              validator: (valor) {
                                if (valor == null ||
                                    valor.trim().isEmpty) {
                                  return 'Informe a descrição do serviço.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            const Text(
                              'Data do serviço *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            const SizedBox(height: 10),

                            InkWell(
                              onTap: escolherData,
                              child: InputDecorator(
                                decoration: decoracao('Data'),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        formatarData(dataSelecionada),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF071D49),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            const Text(
                              'Status *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: azulMN,
                              ),
                            ),
                            const SizedBox(height: 10),

                            DropdownButtonFormField<String>(
                              initialValue: statusSelecionado,
                              decoration: decoracao('Status'),
                              items: [
                                'Pendente',
                                'Em andamento',
                                'Concluído',
                              ].map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() {
                                    statusSelecionado = valor;
                                  });
                                }
                              },
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
                                    onPressed:
                                        carregando ? null : salvar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: azulBotao,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                    ),
                                    icon: const Icon(Icons.save),
                                    label: const Text(
                                      'Salvar Serviço',
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
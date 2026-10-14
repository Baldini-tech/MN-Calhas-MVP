import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _azulMN = Color(0xFF103B66);
const _azulBotao = Color(0xFF1768CF);
const _azulEscuro = Color(0xFF071D49);

String _formatarCentavos(int centavos) {
  final reais = (centavos ~/ 100).toString();
  final agrupado = reais.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return 'R\$ $agrupado,${(centavos % 100).toString().padLeft(2, '0')}';
}

String _formatarValor(dynamic valor) {
  final numero = valor is num
      ? valor.toDouble()
      : double.tryParse(valor.toString().replaceAll(',', '.')) ?? 0;
  return _formatarCentavos((numero * 100).round());
}

class OrcamentosScreen extends StatefulWidget {
  const OrcamentosScreen({super.key});

  @override
  State<OrcamentosScreen> createState() => _OrcamentosScreenState();
}

class _OrcamentosScreenState extends State<OrcamentosScreen> {
  final List<Map<String, dynamic>> _orcamentos = [];
  final List<String> _clientes = [];
  final _pesquisaController = TextEditingController();
  String _filtro = 'Todos';
  String? _mensagem;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _pesquisaController.addListener(_atualizarPesquisa);
    _carregarDados();
  }

  void _atualizarPesquisa() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(_atualizarPesquisa);
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosOrcamentos = prefs.getString('orcamentos');
    final dadosClientes = prefs.getString('clientes');
    final listaOrcamentos = <Map<String, dynamic>>[];
    final nomesClientes = <String>[];

    if (dadosOrcamentos != null) {
      final lista = jsonDecode(dadosOrcamentos) as List;
      listaOrcamentos.addAll(
        lista.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    }
    if (dadosClientes != null) {
      final lista = jsonDecode(dadosClientes) as List;
      for (final item in lista) {
        final nome = (item as Map)['nome']?.toString().trim() ?? '';
        if (nome.isNotEmpty && !nomesClientes.contains(nome)) {
          nomesClientes.add(nome);
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _orcamentos
        ..clear()
        ..addAll(listaOrcamentos);
      _clientes
        ..clear()
        ..addAll(nomesClientes);
      _carregando = false;
    });
  }

  Future<void> _salvarOrcamentos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orcamentos', jsonEncode(_orcamentos));
  }

  Future<void> _abrirFormulario({int? index}) async {
    // Recarrega os clientes caso tenham sido cadastrados desde a última visita.
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('clientes');
    final nomes = <String>[];
    if (dados != null) {
      for (final item in jsonDecode(dados) as List) {
        final nome = (item as Map)['nome']?.toString().trim() ?? '';
        if (nome.isNotEmpty && !nomes.contains(nome)) nomes.add(nome);
      }
    }
    if (!mounted) return;
    _clientes
      ..clear()
      ..addAll(nomes);

    if (_clientes.isEmpty && index == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um cliente primeiro!')),
      );
      return;
    }

    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => _FormularioOrcamentoScreen(
          clientes: List<String>.from(_clientes),
          orcamento: index == null
              ? null
              : Map<String, dynamic>.from(_orcamentos[index]),
        ),
      ),
    );
    if (!mounted || resultado == null) return;
    setState(() {
      if (index == null) {
        _orcamentos.add(resultado);
        _mensagem = 'Orçamento cadastrado com sucesso!';
      } else {
        _orcamentos[index] = resultado;
        _mensagem = 'Orçamento atualizado com sucesso!';
      }
    });
    await _salvarOrcamentos();
  }

  Future<void> _excluir(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir orçamento'),
        content: const Text('Tem certeza que deseja excluir este orçamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    setState(() {
      _orcamentos.removeAt(index);
      _mensagem = 'Orçamento excluído com sucesso!';
    });
    await _salvarOrcamentos();
  }

  bool _gerandoServico = false;

  Future<void> _gerarServico(int index) async {
    if (_gerandoServico || index < 0 || index >= _orcamentos.length) return;
    final orcamento = _orcamentos[index];
    if (orcamento['status'] != 'Aprovado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aprove o orçamento antes de gerar o serviço.'),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerar serviço'),
        content: Text(
          'Criar um serviço pendente para ${orcamento['cliente']} '
          'com a descrição deste orçamento? A data será a de hoje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gerar Serviço'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted || _gerandoServico) return;

    setState(() => _gerandoServico = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final dados = prefs.getString('servicos');
      final servicos = dados == null
          ? <Map<String, dynamic>>[]
          : (jsonDecode(dados) as List)
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();

      // O identificador permanece no orçamento, mesmo após uma edição.
      final id = (orcamento['idIntegracao'] ?? '').toString().isNotEmpty
          ? orcamento['idIntegracao'].toString()
          : 'orc_${DateTime.now().microsecondsSinceEpoch}_$index';
      final jaExiste = servicos.any(
        (servico) => servico['origemOrcamentoId'] == id,
      );
      if (jaExiste) {
        if (mounted) {
          setState(
            () => _mensagem = 'Este orçamento já possui um serviço gerado.',
          );
        }
        return;
      }

      final hoje = DateTime.now();
      final data =
          '${hoje.day.toString().padLeft(2, '0')}/'
          '${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';
      servicos.add({
        'cliente': orcamento['cliente'].toString(),
        'descricao': orcamento['descricao'].toString(),
        'data': data,
        'status': 'Pendente',
        'origemOrcamentoId': id,
      });
      await prefs.setString('servicos', jsonEncode(servicos));
      orcamento['idIntegracao'] = id;
      await _salvarOrcamentos();
      if (!mounted) return;
      setState(
        () => _mensagem =
            'Serviço gerado! Abra Gestão de Serviços para visualizá-lo.',
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível gerar o serviço: $erro')),
      );
    } finally {
      if (mounted) setState(() => _gerandoServico = false);
    }
  }

  List<int> get _filtrados {
    final busca = _pesquisaController.text.trim().toLowerCase();
    return List.generate(_orcamentos.length, (i) => i).where((i) {
      final item = _orcamentos[i];
      final cliente = (item['cliente'] ?? '').toString().toLowerCase();
      final descricao = (item['descricao'] ?? '').toString().toLowerCase();
      final status = (item['status'] ?? 'Pendente').toString();
      return (_filtro == 'Todos' || status == _filtro) &&
          (cliente.contains(busca) || descricao.contains(busca));
    }).toList();
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'Aprovado':
        return const Color(0xFF187A3C);
      case 'Recusado':
        return const Color(0xFFBA3434);
      default:
        return const Color(0xFF946200);
    }
  }

  Widget _cardOrcamento(int index) {
    final item = _orcamentos[index];
    final status = (item['status'] ?? 'Pendente').toString();
    final cor = _corStatus(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E2EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: _azulMN, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (item['cliente'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: _azulEscuro,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (opcao) {
                  if (opcao == 'editar') {
                    _abrirFormulario(index: index);
                  } else if (opcao == 'excluir') {
                    _excluir(index);
                  } else if (opcao == 'gerar') {
                    _gerarServico(index);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'editar', child: Text('Editar')),
                  if (status == 'Aprovado')
                    const PopupMenuItem(
                      value: 'gerar',
                      child: Text('Gerar Serviço'),
                    ),
                  const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (item['descricao'] ?? '').toString(),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _formatarValor(item['valor'] ?? 0),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: _azulMN,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
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
                  colors: [Color(0xFF103B66), Color(0xFF174B7D)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.home, color: Colors.white, size: 58),
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
                          'Gestão de Orçamentos',
                          style: TextStyle(fontSize: 17, color: Colors.white),
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
                      if (_mensagem != null) ...[
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F7E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF238A3B),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_mensagem!)),
                              IconButton(
                                onPressed: () =>
                                    setState(() => _mensagem = null),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                      const Row(
                        children: [
                          Icon(Icons.receipt_long, color: _azulMN, size: 40),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Orçamentos cadastrados',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _azulEscuro,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Consulte e gerencie os orçamentos da sua empresa.',
                        style: TextStyle(color: Color(0xFF405577)),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _pesquisaController,
                        decoration: _decoracao(
                          'Pesquisar cliente ou descrição',
                          Icons.search,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: ['Todos', 'Pendente', 'Aprovado', 'Recusado']
                            .map(
                              (status) => ChoiceChip(
                                label: Text(status),
                                selected: _filtro == status,
                                selectedColor: const Color(0xFFDCEBFF),
                                onSelected: (_) =>
                                    setState(() => _filtro = status),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      if (_carregando)
                        const Center(child: CircularProgressIndicator())
                      else if (filtrados.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 35),
                          child: Center(
                            child: Text('Nenhum orçamento encontrado.'),
                          ),
                        )
                      else
                        ...filtrados.map(_cardOrcamento),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Voltar ao Menu'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _azulMN,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _abrirFormulario(),
                              icon: const Icon(Icons.add),
                              label: const Text('Novo Orçamento'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _azulBotao,
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

InputDecoration _decoracao(String dica, IconData icone) {
  return InputDecoration(
    hintText: dica,
    prefixIcon: Icon(icone, color: _azulMN),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFBAC8DD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _azulBotao, width: 2),
    ),
  );
}

class _FormularioOrcamentoScreen extends StatefulWidget {
  final List<String> clientes;
  final Map<String, dynamic>? orcamento;

  const _FormularioOrcamentoScreen({required this.clientes, this.orcamento});

  @override
  State<_FormularioOrcamentoScreen> createState() =>
      _FormularioOrcamentoScreenState();
}

class _FormularioOrcamentoScreenState
    extends State<_FormularioOrcamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final List<Map<String, dynamic>> _itensOrcamento = [];
  String? _clienteSelecionado;
  String _statusSelecionado = 'Pendente';

  @override
  void initState() {
    super.initState();
    final atual = widget.orcamento;
    if (atual?['itens'] is List) {
      _itensOrcamento.addAll(
        (atual!['itens'] as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
    }
    _descricaoController.text = (atual?['descricao'] ?? '').toString();
    if (atual != null) {
      _valorController.text = _formatarValor(atual['valor'] ?? 0);
      _clienteSelecionado = (atual['cliente'] ?? '').toString();
    }
    if (_clienteSelecionado == null || _clienteSelecionado!.isEmpty) {
      _clienteSelecionado = widget.clientes.isEmpty
          ? null
          : widget.clientes.first;
    }
    final status = (atual?['status'] ?? 'Pendente').toString();
    if (['Pendente', 'Aprovado', 'Recusado'].contains(status)) {
      _statusSelecionado = status;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  double _calcularTotalItem(Map<String, dynamic> item) {
    final valor = (item['valorUnitario'] as num?)?.toDouble() ?? 0;
    final corte = (item['corte'] as num?)?.toDouble() ?? 0;
    final metros = (item['metragem'] as num?)?.toDouble() ?? 0;

    return (corte * valor) * metros;
  }

  double _calcularTotalGeral() {
    return _itensOrcamento.fold<double>(
      0,
      (total, item) => total + _calcularTotalItem(item),
    );
  }

  void _adicionarItem() {
    setState(() {
      _itensOrcamento.add({
        'tipo': 'Calha',
        'metragem': 0.0,
        'corte': 0.0,
        'valorUnitario': 1.40,
      });
    });
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final resultado = <String, dynamic>{
      // Preserva metadados de integração ao editar um orçamento.
      ...?widget.orcamento,
      'cliente': _clienteSelecionado,
      'descricao': _itensOrcamento
          .map((item) => item['tipo'].toString())
          .join(', '),
      'valor': _calcularTotalGeral(),
      'itens': _itensOrcamento,
      'status': _statusSelecionado,
    };
    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.orcamento != null;
    final nomes = List<String>.from(widget.clientes);
    // Mantém selecionável um cliente antigo, mesmo se ele foi excluído do cadastro.
    if (_clienteSelecionado != null && !nomes.contains(_clienteSelecionado)) {
      nomes.insert(0, _clienteSelecionado!);
    }

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
                  colors: [Color(0xFF103B66), Color(0xFF174B7D)],
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
                  const Icon(Icons.home, color: Colors.white, size: 52),
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
                          'Gestão de Orçamentos',
                          style: TextStyle(color: Colors.white, fontSize: 17),
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
                        border: Border.all(color: const Color(0xFFE0E7F0)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  color: _azulMN,
                                  size: 45,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    editando
                                        ? 'Editar Orçamento'
                                        : 'Novo Orçamento',
                                    style: const TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: _azulEscuro,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text('Preencha as informações do orçamento.'),
                            const SizedBox(height: 30),
                            const Text(
                              'Cliente *',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _azulMN,
                              ),
                            ),
                            const SizedBox(height: 9),
                            DropdownButtonFormField<String>(
                              initialValue: _clienteSelecionado,
                              isExpanded: true,
                              decoration: _decoracao(
                                'Selecione o cliente',
                                Icons.person_outline,
                              ),
                              items: nomes
                                  .map(
                                    (nome) => DropdownMenuItem(
                                      value: nome,
                                      child: Text(
                                        nome,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (valor) =>
                                  setState(() => _clienteSelecionado = valor),
                              validator: (valor) => valor == null
                                  ? 'Selecione um cliente.'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(height: 20),

                            OutlinedButton.icon(
                              onPressed: _adicionarItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar Item'),
                            ),

                            ..._itensOrcamento.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        initialValue: item['tipo'] as String?,
                                        decoration: const InputDecoration(
                                          labelText: 'Serviço',
                                          border: OutlineInputBorder(),
                                        ),
                                        items:
                                            [
                                                  'Calha',
                                                  'Rufo',
                                                  'Condutor',
                                                  'Outro',
                                                ]
                                                .map(
                                                  (tipo) => DropdownMenuItem(
                                                    value: tipo,
                                                    child: Text(tipo),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (valor) {
                                          if (valor == null) return;

                                          setState(() {
                                            item['tipo'] = valor;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        initialValue: item['corte'].toString(),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Corte (cm)',
                                          hintText: 'Exemplo: 40',
                                          border: OutlineInputBorder(),
                                          suffixText: 'cm',
                                        ),
                                        onChanged: (valor) {
                                          setState(() {
                                            item['corte'] =
                                                double.tryParse(
                                                  valor.replaceAll(',', '.'),
                                                ) ??
                                                0.0;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        initialValue: item['valorUnitario']
                                            .toString()
                                            .replaceAll('.', ','),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Valor custo',
                                          hintText: 'Exemplo: 1,40',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (valor) {
                                          setState(() {
                                            item['valorUnitario'] =
                                                double.tryParse(
                                                  valor.replaceAll(',', '.'),
                                                ) ??
                                                0.0;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        initialValue: item['metragem']
                                            .toString(),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: const InputDecoration(
                                          labelText: 'Metros',
                                          hintText: 'Exemplo: 10',
                                          suffixText: 'm',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (valor) {
                                          setState(() {
                                            item['metragem'] =
                                                double.tryParse(
                                                  valor.replaceAll(',', '.'),
                                                ) ??
                                                0.0;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Total do serviço: R\$ ${_calcularTotalItem(item).toStringAsFixed(2).replaceAll('.', ',')}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          tooltip: 'Excluir serviço',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _itensOrcamento.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            const SizedBox(height: 16),

                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'TOTAL GERAL',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${_calcularTotalGeral().toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            const SizedBox(height: 24),
                            const Text(
                              'Status *',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _azulMN,
                              ),
                            ),
                            const SizedBox(height: 9),
                            DropdownButtonFormField<String>(
                              initialValue: _statusSelecionado,
                              decoration: _decoracao(
                                'Selecione o status',
                                Icons.info_outline,
                              ),
                              items: ['Pendente', 'Aprovado', 'Recusado']
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => _statusSelecionado = valor);
                                }
                              },
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: _azulMN),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Os campos marcados com * são obrigatórios.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                    ),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _salvar,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Salvar Orçamento'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _azulBotao,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

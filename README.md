# MN Calhas — Sistema de Gestão

## Sobre o projeto

O MN Calhas é um sistema desenvolvido em Flutter para auxiliar
na organização e no gerenciamento das atividades de uma empresa
especializada em instalação de calhas e rufos.

O projeto foi desenvolvido como Produto Mínimo Viável (MVP)
para a disciplina de Projeto de Software da Unifran.

## Problema identificado

A empresa realiza o controle de clientes, orçamentos e serviços
principalmente por meio de registros em papel.

Esse processo dificulta a localização das informações,
a organização dos atendimentos e o acompanhamento dos serviços.

## Objetivo

Digitalizar os principais processos administrativos da empresa,
oferecendo uma interface simples e acessível.

## Funcionalidades

### Gestão de clientes

- Cadastro de clientes.
- Consulta e pesquisa de clientes.
- Edição de informações cadastrais.
- Exclusão de registros.

### Gestão de orçamentos

- Cadastro de orçamentos.
- Consulta e pesquisa.
- Registro de valores.
- Controle dos estados Pendente, Aprovado e Recusado.
- Geração de serviços a partir de orçamentos aprovados.

### Gestão de serviços

- Cadastro de serviços.
- Consulta e acompanhamento.
- Controle dos estados Pendente, Em andamento e Concluído.

## Tecnologias utilizadas

- Flutter
- Dart
- SharedPreferences
- Git
- GitHub

## Armazenamento

O MVP utiliza armazenamento local com SharedPreferences.

Essa abordagem permite demonstrar as funcionalidades
essenciais sem depender de um servidor externo.

## Como executar

### Requisitos

- Flutter SDK instalado.
- Visual Studio Code ou outra IDE compatível.
- Navegador Google Chrome.

### Instalação

Clone o repositório:

```bash
git clone https://github.com/Baldini-tech/MN-Calhas-MVP.git
```

Entre na pasta:

```bash
cd MN-Calhas-MVP
```

Instale as dependências:

```bash
flutter pub get
```

Execute o projeto:

```bash
flutter run -d chrome
```

## Limitações do MVP

- Os dados são armazenados localmente.
- Não existe sincronização entre dispositivos.
- O sistema ainda não possui integração com um banco de dados remoto.

## Evoluções futuras

- Implementação de autenticação.
- Integração com banco de dados.
- Sincronização entre dispositivos.
- Relatórios administrativos.
- Melhorias na experiência do usuário.

## Instituição

Universidade de Franca — Unifran

Curso: Análise e Desenvolvimento de Sistemas

Projeto acadêmico: MN Calhas

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'screens/clientes_screen.dart';
import 'screens/orcamentos_screen.dart';
import 'screens/servicos_screen.dart';

void main() {
  runApp(const MNCalhasApp());
}

class MNCalhasApp extends StatelessWidget {
  const MNCalhasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),

supportedLocales: const [
  Locale('pt', 'BR'),
],

localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
      title: 'MN Calhas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color azulEscuro = Color(0xFF103B66);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // CABEÇALHO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: azulEscuro,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.home_work,
                      color: Colors.white,
                      size: 55,
                    ),
                    SizedBox(width: 15),
                    Expanded(
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
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // CONTEÚDO
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD6E9FA),
                            Color(0xFFEDF6FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Organização e mais resultados para a sua empresa.',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: azulEscuro,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                   menuCard(
  icon: Icons.people,
  title: 'Clientes',
  subtitle: 'Cadastre e gerencie seus clientes',
  color: const Color(0xFFE3F1FF),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientesScreen(),
      ),
    );
  },
),

menuCard(
  icon: Icons.description,
  title: 'Orçamentos',
  subtitle: 'Crie e acompanhe os orçamentos',
  color: const Color(0xFFFFF0D9),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrcamentosScreen(),
      ),
    );
  },
),

                    menuCard(
                      icon: Icons.build,
                      title: 'Serviços',
                      subtitle: 'Cadastre e acompanhe os serviços',
                      color: const Color(0xFFD4F5D0),
                      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ServicosScreen(),
    ),
  );
},
                    ),

                    menuCard(
                      icon: Icons.logout,
                      title: 'Sair',
                      subtitle: 'Encerrar o acesso ao sistema',
                      color: const Color(0xFFFFE0E0),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Versão acadêmica: acesso sem login.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 45,
                  color: azulEscuro,
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: azulEscuro,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: azulEscuro,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: azulEscuro,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
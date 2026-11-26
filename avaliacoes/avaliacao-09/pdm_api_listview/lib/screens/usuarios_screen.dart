import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_services.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Usuario>> _futureUsuarios;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _futureUsuarios = _apiService.buscarUsuarios();
    });
  }

  Future<void> _recarregarLista() async {
    _carregarDados();
    await _futureUsuarios;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuários'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _recarregarLista,
        child: FutureBuilder<List<Usuario>>(
          future: _futureUsuarios,
          builder: (context, snapshot) {
            // 1. Estado de Carregamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Buscando usuários...'),
                  ],
                ),
              );
            }

            // 2. Estado de Erro
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _carregarDados,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 3. Estado de Lista Vazia
            final usuarios = snapshot.data ?? [];
            if (usuarios.isEmpty) {
              return const Center(
                child: Text('Nenhum usuário encontrado.'),
              );
            }

            // 4. Estado de Sucesso (ListView Dinâmica)
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: Text(usuario.nome[0].toUpperCase()),
                    ),
                    title: Text(
                      usuario.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(child: Text(usuario.email)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.business, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(child: Text(usuario.empresa)),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _mostrarDetalhes(context, usuario),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(usuario.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: #${usuario.id}'),
            const SizedBox(height: 8),
            Text('E-mail: ${usuario.email}'),
            const SizedBox(height: 8),
            Text('Telefone: ${usuario.telefone}'),
            const SizedBox(height: 8),
            Text('Empresa: ${usuario.empresa}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
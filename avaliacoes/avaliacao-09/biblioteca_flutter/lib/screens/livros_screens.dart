import 'package:flutter/material.dart';

import '../models/livro_model.dart';
import '../services/livro_service.dart';

class LivrosScreen extends StatefulWidget {
  const LivrosScreen({super.key});

  @override
  State<LivrosScreen> createState() => _LivrosScreenState();
}

class _LivrosScreenState extends State<LivrosScreen> {
  final LivroService _livroService = LivroService();
  final TextEditingController _buscaController = TextEditingController();

  List<Livro> _livros = [];
  bool _estaCarregando = true;
  String? _mensagemErro;
  String _termoAtual = 'flutter'; // Termo padrão para a primeira busca

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // Método central para buscar dados e atualizar o estado da UI
  Future<void> _carregarLivros([String? novoTermo]) async {
    if (novoTermo != null && novoTermo.trim().isNotEmpty) {
      _termoAtual = novoTermo.trim();
    }

    setState(() {
      _estaCarregando = true;
      _mensagemErro = null;
    });

    try {
      final resultado = await _livroService.buscarLivros(_termoAtual);
      if (!mounted) return;
      setState(() {
        _livros = resultado;
        _estaCarregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mensagemErro = e.toString().replaceAll('Exception: ', '');
        _estaCarregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca Acadêmica'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de busca em tempo real
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _buscaController,
              textInputAction: TextInputAction.search,
              onSubmitted: (valor) => _carregarLivros(valor),
              decoration: InputDecoration(
                hintText: 'Buscar livros (ex: algoritmos, python, redes)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _carregarLivros(_buscaController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // Corpo dinâmico conforme o estado da requisição
          Expanded(child: _construirCorpo()),
        ],
      ),
    );
  }

  Widget _construirCorpo() {
    // 1. Estado de Carregamento
    if (_estaCarregando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 16),
            Text('Buscando acervo na API...'),
          ],
        ),
      );
    }

    // 2. Estado de Erro (Rede, Timeout, etc.)
    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _carregarLivros(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Estado de Lista Vazia
    if (_livros.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum livro encontrado para essa busca.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // 4. Estado de Sucesso com Pull-to-Refresh e ListView.builder
    return RefreshIndicator(
      onRefresh: () => _carregarLivros(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _livros.length,
        itemBuilder: (context, index) {
          final livro = _livros[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: livro.urlCapa != null
                    ? Image.network(
                        livro.urlCapa!,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _iconePadrao(),
                      )
                    : _iconePadrao(),
              ),
              title: Text(
                livro.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Autor: ${livro.autor}\n'
                  'Ano: ${livro.anoPublicacao ?? 'Não informado'}',
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _iconePadrao() {
    return Container(
      width: 50,
      height: 75,
      color: Colors.indigo.shade50,
      child: const Icon(Icons.menu_book, color: Colors.indigo),
    );
  }
}

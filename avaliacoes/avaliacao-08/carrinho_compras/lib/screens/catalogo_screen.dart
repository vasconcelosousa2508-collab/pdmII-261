import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../providers/carrinho_provider.dart';
import 'carrinho_screen.dart';

class CatalogoScreen extends StatelessWidget {
  CatalogoScreen({super.key});

  // Lista fictícia de produtos
  final List<Produto> produtosDisponiveis = [
    Produto(id: '1', nome: 'Notebook Gamer', preco: 4500.00),
    Produto(id: '2', nome: 'Mouse Sem Fio', preco: 120.50),
    Produto(id: '3', nome: 'Teclado Mecânico', preco: 350.00),
    Produto(id: '4', nome: 'Monitor 27" 144Hz', preco: 1499.90),
    Produto(id: '5', nome: 'Headset Surround', preco: 280.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja Tech'),
        actions: [
          // Consumer escuta apenas as mudanças necessárias para o ícone do carrinho
          Consumer<CarrinhoProvider>(
            builder: (_, carrinho, ch) => Badge(
              label: Text(carrinho.quantidadeItens.toString()),
              isLabelVisible: carrinho.quantidadeItens > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CarrinhoScreen()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        itemCount: produtosDisponiveis.length,
        itemBuilder: (ctx, i) {
          final prod = produtosDisponiveis[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(prod.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('R\$ ${prod.preco.toStringAsFixed(2)}'),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Adicionar'),
                onPressed: () {
                  // listen: false pois aqui apenas disparamos uma ação
                  Provider.of<CarrinhoProvider>(context, listen: false).adicionarItem(prod);

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${prod.nome} adicionado ao carrinho!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
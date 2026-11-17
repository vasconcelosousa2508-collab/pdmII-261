import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrinho_provider.dart';

class CarrinhoScreen extends StatelessWidget {
  const CarrinhoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrinho = Provider.of<CarrinhoProvider>(context);
    final itensLista = carrinho.itens.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
      ),
      body: Column(
        children: [
          // Cartão de Resumo do Valor Total
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Chip(
                    label: Text(
                      'R\$ ${carrinho.valorTotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Lista de itens no carrinho
          Expanded(
            child: itensLista.isEmpty
                ? const Center(child: Text('Seu carrinho está vazio.'))
                : ListView.builder(
              itemCount: itensLista.length,
              itemBuilder: (ctx, i) {
                final item = itensLista[i];
                return ListTile(
                  title: Text(item.produto.nome),
                  subtitle: Text(
                    'Subtotal: R\$ ${(item.produto.preco * item.quantidade).toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => carrinho.removerUnidade(item.produto.id),
                      ),
                      Text('${item.quantidade}', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => carrinho.adicionarItem(item.produto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => carrinho.removerItemCompleto(item.produto.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botão de Finalizar Compra
          if (itensLista.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    carrinho.limparCarrinho();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compra finalizada com sucesso!')),
                    );
                  },
                  child: const Text('FINALIZAR COMPRA', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
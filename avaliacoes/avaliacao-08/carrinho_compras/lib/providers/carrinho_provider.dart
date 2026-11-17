import 'package:flutter/material.dart';
import '../models/produto.dart';

class ItemCarrinho {
  final Produto produto;
  int quantidade;

  ItemCarrinho({required this.produto, this.quantidade = 1});
}

class CarrinhoProvider with ChangeNotifier {
  // Mapa privado que guarda os itens usando o ID do produto como chave
  final Map<String, ItemCarrinho> _itens = {};

  Map<String, ItemCarrinho> get itens => {..._itens};

  // Retorna a quantidade total de produtos diferentes no carrinho
  int get quantidadeItens => _itens.length;

  // Calcula o valor total da compra
  double get valorTotal {
    double total = 0.0;
    _itens.forEach((key, item) {
      total += item.produto.preco * item.quantidade;
    });
    return total;
  }

  // Adiciona um produto ou incrementa sua quantidade
  void adicionarItem(Produto produto) {
    if (_itens.containsKey(produto.id)) {
      _itens.update(
        produto.id,
            (itemExistente) => ItemCarrinho(
          produto: itemExistente.produto,
          quantidade: itemExistente.quantidade + 1,
        ),
      );
    } else {
      _itens.putIfAbsent(
        produto.id,
            () => ItemCarrinho(produto: produto),
      );
    }
    notifyListeners(); // Notifica a interface para se redesenhar
  }

  // Diminui a quantidade ou remove se chegar a zero
  void removerUnidade(String produtoId) {
    if (!_itens.containsKey(produtoId)) return;

    if (_itens[produtoId]!.quantidade > 1) {
      _itens.update(
        produtoId,
            (itemExistente) => ItemCarrinho(
          produto: itemExistente.produto,
          quantidade: itemExistente.quantidade - 1,
        ),
      );
    } else {
      _itens.remove(produtoId);
    }
    notifyListeners();
  }

  // Remove o produto completamente do carrinho
  void removerItemCompleto(String produtoId) {
    _itens.remove(produtoId);
    notifyListeners();
  }

  // Limpa todo o carrinho
  void limparCarrinho() {
    _itens.clear();
    notifyListeners();
  }
}
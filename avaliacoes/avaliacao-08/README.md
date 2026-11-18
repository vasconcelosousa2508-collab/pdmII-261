# Tutorial: Carrinho de Compras em Flutter com Gerenciamento de Estado (Provider)

Neste tutorial, você vai construir um aplicativo de e-commerce simples onde o usuário pode visualizar uma lista de produtos, adicionar itens ao carrinho, alterar quantidades, remover produtos e acompanhar o valor total em tempo real usando o pacote **Provider**.

## 1. Pré-requisitos e Configuração do Projeto

Certifique-se de ter o **Flutter SDK** instalado e configurado em sua máquina.

1. Abra o terminal e crie um novo projeto Flutter:
   ```bash
   flutter create carrinho_compras
   cd carrinho_compras
   ```

2. Adicione a dependência do **Provider** ao projeto executando o comando:
   ```bash
   flutter pub add provider
   ```
   *(Isso atualizará automaticamente o seu arquivo `pubspec.yaml` com a versão mais recente do pacote).*

---

## 2. Estrutura de Pastas

Para manter o código organizado, crie a seguinte estrutura dentro da pasta `lib/`:

```text
lib/
├── models/
│   └── produto.dart
├── providers/
│   └── carrinho_provider.dart
├── screens/
│   ├── catalogo_screen.dart
│   └── carrinho_screen.dart
└── main.dart
```

---

## 3. Passo a Passo do Código

### Passo 1: Criar o Modelo de Dados (`lib/models/produto.dart`)
Este arquivo define a estrutura de um produto no aplicativo.

```dart
class Produto {
  final String id;
  final String nome;
  final double preco;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
  });
}
```

### Passo 2: Criar o Gerenciador de Estado (`lib/providers/carrinho_provider.dart`)
Aqui fica toda a lógica de negócios. Usamos o `ChangeNotifier` para avisar as telas sempre que um item for adicionado ou removido.

```dart
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
```

### Passo 3: Criar a Tela do Catálogo (`lib/screens/catalogo_screen.dart`)
A tela principal exibe os produtos disponíveis e um ícone no topo mostrando quantos itens já estão no carrinho.

```dart
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
```

### Passo 4: Criar a Tela do Carrinho (`lib/screens/carrinho_screen.dart`)
Nesta tela, o usuário visualiza os itens escolhidos, ajusta quantidades, vê o valor total e finaliza o pedido.

```dart
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
```

### Passo 5: Configurar o Arquivo Principal (`lib/main.dart`)
Envolvemos o aplicativo com o `ChangeNotifierProvider` para que o estado do carrinho fique acessível em qualquer tela.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/carrinho_provider.dart';
import 'screens/catalogo_screen.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => CarrinhoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Carrinho Flutter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: CatalogoScreen(),
      ),
    );
  }
}
```

---

## 4. Como Executar a Aplicação no Celular Físico

Para cumprir a segunda parte da atividade (rodar no smartphone), siga estes passos:

### No Celular (Android):
1. Vá em **Configurações > Sobre o telefone**.
2. Toque 7 vezes seguidas sobre **Número da versão** (ou *Número de compilação*) até aparecer a mensagem *"Você agora é um desenvolvedor"*.
3. Volte em **Configurações > Sistema > Opções do desenvolvedor**.
4. Ative a opção **Depuração USB**.

### No Computador:
1. Conecte o celular ao computador usando um cabo USB (se aparecer um pop-up no celular pedindo permissão para depuração USB, toque em **Permitir**).
2. No terminal do seu projeto Flutter, verifique se o aparelho foi reconhecido:
   ```bash
   flutter devices
   ```
   *(O nome/modelo do seu celular deverá aparecer na lista).*
3. Execute o aplicativo diretamente no aparelho:
   ```bash
   flutter run
   ```


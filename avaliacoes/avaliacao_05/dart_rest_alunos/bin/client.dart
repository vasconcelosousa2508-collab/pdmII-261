// cliente.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// Representação do Aluno no lado do Cliente
class Aluno {
  final int id;
  final String nome;
  final String disciplina;
  final double media;
  final int faltas;

  Aluno({
    required this.id,
    required this.nome,
    required this.disciplina,
    required this.media,
    required this.faltas,
  });

  factory Aluno.fromJson(Map json) {
    return Aluno(
      id: json['id'] as int,
      nome: json['nome'] as String,
      disciplina: json['disciplina'] as String,
      media: (json['media'] as num).toDouble(),
      faltas: json['faltas'] as int,
    );
  }

  // Regra pedida no exercício para gerar a mensagem
  String get mensagem {
    if (faltas > 20) {
      return 'Reprovado por Faltas';
    } else if (media < 6.0) {
      return 'Reprovado';
    } else {
      return 'Aprovado';
    }
  }
}

Future main() async {
  final url = Uri.parse('http://localhost:8080/api/alunos');

  try {
    // 2) Acessa o Servidor Web via GET
    print('Buscando alunos no servidor...\n');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map body = jsonDecode(response.body);
      final List listaJson = body['dados'];

      // Converte o JSON recebido em Objetos Aluno
      List alunos = listaJson.map((json) => Aluno.fromJson(json)).toList();

      // Imprime o cabeçalho
      print('----------------------------------------------------------------------------------');
      print('ID | NOME         | DISCIPLINA           | MEDIA | FALTAS | MENSAGEM');
      print('----------------------------------------------------------------------------------');

      // Imprime cada aluno no formato pedido
      for (var aluno in alunos) {
        print('(${aluno.id}  |${aluno.nome.padRight(12)} | ${aluno.disciplina.padRight(20)} | ${aluno.media.toStringAsFixed(1).padRight(5)} | ${aluno.faltas.toString().padRight(6)} | ${aluno.mensagem})');
      }
      print('----------------------------------------------------------------------------------');
    } else {
      print('Erro ao buscar dados: Status ${response.statusCode}');
    }
  } catch (e) {
    print('Certifique-se de que o servidor está rodando! Erro: $e');
  }
}
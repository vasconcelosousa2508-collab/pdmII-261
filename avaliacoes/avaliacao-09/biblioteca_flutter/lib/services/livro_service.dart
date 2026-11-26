import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/livro_model.dart';

class LivroService {
  static const String _baseUrl = 'https://openlibrary.org/search.json';

  Future<List<Livro>> buscarLivros(String termoBusca) async {
    final query = termoBusca.trim().isEmpty ? 'computacao' : termoBusca;
    final uri = Uri.parse(_baseUrl)
        .replace(queryParameters: {'q': query, 'limit': '30'});

    try {
      // Requisição HTTP GET com limite de tempo (timeout) de 10 segundos
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Decodifica o corpo da resposta em UTF-8 para manter acentuação correta
        final Map<String, dynamic> dadosJson = json.decode(
          utf8.decode(response.bodyBytes),
        );

        final List<dynamic> docs = dadosJson['docs'] ?? [];

        // Converte cada item JSON em um objeto Livro
        return docs.map((item) => Livro.fromJson(item)).toList();
      } else {
        throw Exception('Erro no servidor (Código: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception(
        'Sem conexão com a internet. Verifique seu Wi-Fi ou dados.',
      );
    } on TimeoutException {
      throw Exception('A requisição demorou muito. Tente novamente.');
    } catch (e) {
      throw Exception('Falha ao carregar os dados: $e');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/users';

  Future<List<Usuario>> buscarUsuarios() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> dadosJson = jsonDecode(response.body);
        return dadosJson.map((item) => Usuario.fromJson(item)).toList();
      } else {
        throw Exception('Erro no servidor (Código: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Sem conexão com a internet. Verifique sua rede.');
    } on TimeoutException {
      throw Exception('Tempo limite excedido. O servidor demorou a responder.');
    } on FormatException {
      throw Exception('Erro ao processar os dados recebidos da API.');
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado: $e');
    }
  }
}
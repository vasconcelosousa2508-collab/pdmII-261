import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class Aluno {
  final int id;
  final String nome;
  final String email;
  final String curso;
  final int idade;
  final double media;
  final bool ativo;

  const Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.curso,
    required this.idade,
    required this.media,
    required this.ativo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'curso': curso,
        'idade': idade,
        'media': media,
        'ativo': ativo,
      };

  static Aluno fromJson(Map<String, dynamic> json) => Aluno(
        id: json['id'] as int,
        nome: json['nome'] as String,
        email: json['email'] as String,
        curso: json['curso'] as String,
        idade: json['idade'] as int,
        media: (json['media'] as num).toDouble(),
        ativo: json['ativo'] as bool? ?? true,
      );
}

final List<Aluno> alunos = [
  const Aluno(
    id: 1,
    nome: 'Ana Souza',
    email: 'ana.souza@example.com',
    curso: 'Engenharia de Computação',
    idade: 21,
    media: 8.7,
    ativo: true,
  ),
  const Aluno(
    id: 2,
    nome: 'Bruno Lima',
    email: 'bruno.lima@example.com',
    curso: 'Engenharia Mecânica',
    idade: 23,
    media: 7.9,
    ativo: true,
  ),
  const Aluno(
    id: 3,
    nome: 'Carla Mendes',
    email: 'carla.mendes@example.com',
    curso: 'Sistemas de Informação',
    idade: 20,
    media: 9.2,
    ativo: true,
  ),
  const Aluno(
    id: 4,
    nome: 'Diego Alves',
    email: 'diego.alves@example.com',
    curso: 'Engenharia Civil',
    idade: 25,
    media: 6.8,
    ativo: false,
  ),
];

Response jsonResponse(
  Object body, {
  int status = 200,
}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Response _listarAlunos(Request request) {
  final query = request.url.queryParameters;
  final curso = query['curso']?.toLowerCase();
  final ativo = query['ativo'];

  var resultado = alunos.where((aluno) {
    final correspondeCurso = curso == null ||
        aluno.curso.toLowerCase().contains(curso);
    final correspondeAtivo = ativo == null ||
        aluno.ativo.toString() == ativo.toLowerCase();
    return correspondeCurso && correspondeAtivo;
  }).toList();

  final nome = query['nome']?.toLowerCase();
  if (nome != null) {
    resultado = resultado
        .where((aluno) => aluno.nome.toLowerCase().contains(nome))
        .toList();
  }

  return jsonResponse({
    'total': resultado.length,
    'dados': resultado.map((aluno) => aluno.toJson()).toList(),
  });
}

Response _buscarAluno(Request request, String id) {
  final idNumerico = int.tryParse(id);
  if (idNumerico == null) {
    return jsonResponse({'erro': 'O id deve ser um número inteiro.'}, status: 400);
  }

  final aluno = alunos.where((item) => item.id == idNumerico).firstOrNull;
  if (aluno == null) {
    return jsonResponse({'erro': 'Aluno não encontrado.'}, status: 404);
  }

  return jsonResponse(aluno.toJson());
}

Future<Response> _criarAluno(Request request) async {
  try {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final novoAluno = Aluno.fromJson({
      ...json,
      'id': alunos.isEmpty ? 1 : alunos.last.id + 1,
    });

    alunos.add(novoAluno);
    return jsonResponse(novoAluno.toJson(), status: 201);
  } on FormatException {
    return jsonResponse({'erro': 'JSON inválido.'}, status: 400);
  } catch (_) {
    return jsonResponse({
      'erro': 'Dados inválidos. Informe nome, email, curso, idade e media.',
    }, status: 400);
  }
}

Response _health(Request request) => jsonResponse({
      'status': 'ok',
      'servico': 'api-alunos',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });

Router createRouter() {
  final router = Router()
    ..get('/health', _health)
    ..get('/api/alunos', _listarAlunos)
    ..get('/api/alunos/<id>', _buscarAluno)
    ..post('/api/alunos', _criarAluno);

  return router;
}

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final address = InternetAddress.anyIPv4;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createRouter().call);

  final server = await shelf_io.serve(handler, address, port);
  server.autoCompress = true;

  print('Servidor iniciado em http://${server.address.host}:${server.port}');
}
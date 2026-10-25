import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class Aluno {
  final int id;
  final String nome;
  final String disciplina;
  final double media;
  final int faltas;

  const Aluno({
    required this.id,
    required this.nome,
    required this.disciplina,
    required this.media,
    required this.faltas,
  });

  Map toJson() => {
        'id': id,
        'nome': nome,
        'disciplina': disciplina,
        'media': media,
        'faltas': faltas,
      };

  static Aluno fromJson(Map json) => Aluno(
        id: json['id'] as int,
        nome: json['nome'] as String,
        disciplina: json['disciplina'] as String,
        media: (json['media'] as num).toDouble(),
        faltas: json['faltas'] as int,
      );
}

final List alunos = [
  const Aluno(id: 1, nome: 'Ana Souza', disciplina: 'PDM', media: 8.5, faltas: 10),
  const Aluno(id: 2, nome: 'Bruno Lima', disciplina: 'Estrutura de Dados', media: 5.0, faltas: 4),
  const Aluno(id: 3, nome: 'Carla Mendes', disciplina: 'Redes', media: 9.0, faltas: 25),
  const Aluno(id: 4, nome: 'Diego Alves', disciplina: 'Banco de Dados', media: 4.5, faltas: 22),
];

Response jsonResponse(Object body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Response _listarAlunos(Request request) {
  return jsonResponse({
    'total': alunos.length,
    'dados': alunos.map((aluno) => aluno.toJson()).toList(),
  });
}

Router createRouter() {
  final router = Router()..get('/api/alunos', _listarAlunos);
  return router;
}

Future main() async {
  final handler = const Pipeline().addHandler(createRouter().call);
  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Servidor rodando em http://(\{server.address.host}:\){server.port}');
}
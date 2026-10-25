import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  final String dbPath = join(Directory.current.path, 'alunos.db');

  Database? db;

  try {
    db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          try {
            await db.execute('''
              CREATE TABLE tb_alunos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nome TEXT NOT NULL,
                idade INTEGER NOT NULL,
                curso TEXT NOT NULL
              )
            ''');
            print('Tabela "tb_alunos" criada com sucesso!');
          } catch (e) {
            print('Erro ao criar a tabela: $e');
            rethrow;
          }
        },
      ),
    );
    print('Banco de dados aberto/criado no caminho: $dbPath');

    await inserindoAlunos(db);

    await listarAlunos(db);

  } catch (e) {
    print('Falha geral nas operações com o banco de dados: $e');
  } finally {
    if (db != null && db.isOpen) {
      await db.close();
      print('Conexão com o banco de dados fechada.');
    }
  }
}

Future<void> inserindoAlunos(Database db) async {
  final List<Map<String, dynamic>> novosAlunos = [
    {'nome': 'Ana Silva', 'idade': 20, 'curso': 'Engenharia de Software'},
    {'nome': 'Bruno Souza', 'idade': 22, 'curso': 'Ciência da Computação'},
    {'nome': 'Carla Dias', 'idade': 21, 'curso': 'Sistemas de Informação'},
  ];

  try {
    for (var aluno in novosAlunos) {
      int id = await db.insert(
        'tb_alunos',
        aluno,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Aluno inserido com sucesso: ${aluno['nome']} (ID: $id)');
    }
  } catch (e) {
    print('Erro ao inserir alunos no banco de dados: $e');
  }
}

Future<void> listarAlunos(Database db) async {
  try {
    final List<Map<String, dynamic>> alunos = await db.query('tb_alunos');

    print('\n--- Lista de Alunos Registrados ---');
    if (alunos.isEmpty) {
      print('Nenhum aluno encontrado.');
      return;
    }

    for (var aluno in alunos) {
      print(
        'ID: ${aluno['id']} | Nome: ${aluno['nome']} | Idade: ${aluno['idade']} | Curso: ${aluno['curso']}',
      );
    }
    print('-----------------------------------\n');
  } catch (e) {
    print('Erro ao listar o conteúdo da tabela "tb_alunos": $e');
  }
}
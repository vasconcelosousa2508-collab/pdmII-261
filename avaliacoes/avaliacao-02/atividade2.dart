import 'dart:convert';

// Agregação e Composição

class Dependente {
  late String _nome;

  Dependente(String nome) {
    this._nome = nome;
  }
}

class Funcionario {
  late String _nome;
  late List<Dependente> _dependentes;

  Funcionario(String nome, List<Dependente> dependentes) {
    this._nome = nome;
    this._dependentes = dependentes;
  }
}

class EquipeProjeto {
  late String _nomeProjeto;
  late List<Funcionario> _funcionarios;

  EquipeProjeto(String nomeprojeto, List<Funcionario> funcionarios) {
    _nomeProjeto = nomeprojeto;
    _funcionarios = funcionarios;
  }
}

void main() {
  Dependente dep1 = Dependente('Joana');
  Dependente dep2 = Dependente('Adora');
  Dependente dep3 = Dependente('Leo');
  Dependente dep4 = Dependente('Mara');
  Dependente dep5 = Dependente('Soraya');
  Dependente dep6 = Dependente('Louisiane');
  Dependente dep7 = Dependente('Rafa');
  Dependente dep8 = Dependente('Clara');

  Funcionario func1 = Funcionario('Lian', [dep1, dep2]);
  Funcionario func2 = Funcionario('Lanah', [dep3, dep5, dep6]);
  Funcionario func3 = Funcionario('Lucas', [dep4]);
  Funcionario func4 = Funcionario('Gui', []);

  List<Funcionario> listaFuncionarios = [func1, func2, func3, func4];

  EquipeProjeto equipe = EquipeProjeto("App Infantil", listaFuncionarios);

  Map<String, dynamic> equipeParaMap(EquipeProjeto projeto) {
    return {
      'nomeProjeto': projeto._nomeProjeto,
      'funcionarios': projeto._funcionarios
          .map(
            (f) => {
              'nome': f._nome,
              'dependentes': f._dependentes
                  .map((d) => {'nome': d._nome})
                  .toList(),
            },
          )
          .toList(),
    };
  }

  String jsonResultado = JsonEncoder.withIndent(
    '  ',
  ).convert(equipeParaMap(equipe));

  print(jsonResultado);
}

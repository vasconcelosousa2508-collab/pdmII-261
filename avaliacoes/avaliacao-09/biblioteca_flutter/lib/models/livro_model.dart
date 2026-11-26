class Livro {
  final String titulo;
  final String autor;
  final int? anoPublicacao;
  final int? capaId;

  Livro({
    required this.titulo,
    required this.autor,
    this.anoPublicacao,
    this.capaId,
  });

  // Fábrica para converter o Map (JSON) em um objeto Livro
  factory Livro.fromJson(Map<String, dynamic> json) {
    // A API retorna uma lista de autores; pegamos o primeiro ou definimos um padrão
    final autores = json['author_name'] as List<dynamic>?;
    final nomeAutor = (autores != null && autores.isNotEmpty)
        ? autores.first.toString()
        : 'Autor desconhecido';

    return Livro(
      titulo: json['title'] ?? 'Título indisponível',
      autor: nomeAutor,
      anoPublicacao: json['first_publish_year'],
      capaId: json['cover_i'],
    );
  }

  // URL dinâmica da capa do livro
  String? get urlCapa => capaId != null
      ? 'https://covers.openlibrary.org/b/id/$capaId-M.jpg'
      : null;
}

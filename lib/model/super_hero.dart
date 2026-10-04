/// Modelo que representa um personagem retornado pela SuperHero API.
///
/// Obs.: o nome da classe é SuperHero (e não Hero) para não conflitar
/// com o widget `Hero` que já existe no Flutter.
class SuperHero {
  final String id;
  final String name;
  final String fullName;
  final String publisher;
  final String alignment;
  final String race;
  final String gender;
  final String occupation;
  final String firstAppearance;
  final String imageUrl;

  /// Valores de 0 a 100. Fica null quando a API não tem o dado ("null").
  final Map<String, int?> powerstats;

  SuperHero({
    required this.id,
    required this.name,
    required this.fullName,
    required this.publisher,
    required this.alignment,
    required this.race,
    required this.gender,
    required this.occupation,
    required this.firstAppearance,
    required this.imageUrl,
    required this.powerstats,
  });

  /// Cria um SuperHero a partir do JSON da API.
  factory SuperHero.fromJson(Map<String, dynamic> json) {
    final bio = _map(json['biography']);
    final appearance = _map(json['appearance']);
    final work = _map(json['work']);
    final image = _map(json['image']);
    final stats = _map(json['powerstats']);

    const chaves = [
      'intelligence',
      'strength',
      'speed',
      'durability',
      'power',
      'combat',
    ];

    return SuperHero(
      id: _texto(json['id']),
      name: _texto(json['name']),
      fullName: _texto(bio['full-name']),
      publisher: _texto(bio['publisher']),
      alignment: _texto(bio['alignment']),
      race: _texto(appearance['race']),
      gender: _texto(appearance['gender']),
      occupation: _texto(work['occupation']),
      firstAppearance: _texto(bio['first-appearance']),
      imageUrl: image['url']?.toString() ?? '',
      powerstats: {
        for (final c in chaves) c: int.tryParse(stats[c]?.toString() ?? ''),
      },
    );
  }
}

/// Garante que o valor é um Map (a API às vezes devolve campos faltando).
Map<String, dynamic> _map(dynamic valor) =>
    valor is Map<String, dynamic> ? valor : <String, dynamic>{};

/// A API devolve a string "null" ou "-" quando não tem a informação.
String _texto(dynamic valor) {
  final t = valor?.toString().trim() ?? '';
  if (t.isEmpty || t == 'null' || t == '-') return 'Não informado';
  return t;
}

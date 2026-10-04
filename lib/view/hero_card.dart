import 'package:flutter/material.dart';
import 'package:apk_giphy/model/super_hero.dart';

class HeroCard extends StatelessWidget {
  final SuperHero heroi;
  const HeroCard({super.key, required this.heroi});

  static const Map<String, String> _rotulos = {
    'intelligence': 'Inteligência',
    'strength': 'Força',
    'speed': 'Velocidade',
    'durability': 'Durabilidade',
    'power': 'Poder',
    'combat': 'Combate',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _foto(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heroi.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _linha('Nome real', heroi.fullName),
                      _linha('Editora', heroi.publisher),
                      _linha('Alinhamento', _alinhamento(heroi.alignment)),
                      _linha('Raça', heroi.race),
                      _linha('Gênero', heroi.gender),
                      _linha('Ocupação', heroi.occupation),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Poderes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final entrada in heroi.powerstats.entries)
              _barra(_rotulos[entrada.key] ?? entrada.key, entrada.value),
            const SizedBox(height: 10),
            _linha('1ª aparição', heroi.firstAppearance),
          ],
        ),
      ),
    );
  }

  Widget _foto() {
    final placeholder = Container(
      width: 110,
      height: 150,
      color: Colors.grey[800],
      child: const Icon(Icons.person, size: 48, color: Colors.white54),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: heroi.imageUrl.isEmpty
          ? placeholder
          : Image.network(
              heroi.imageUrl,
              width: 110,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }

  Widget _linha(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$rotulo: ',
              style: const TextStyle(color: Colors.white54),
            ),
            TextSpan(
              text: valor,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barra(String rotulo, int? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(rotulo, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (valor ?? 0) / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[800],
                color: Colors.amber,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              valor?.toString() ?? 'N/D',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _alinhamento(String valor) {
    switch (valor.toLowerCase()) {
      case 'good':
        return 'Herói';
      case 'bad':
        return 'Vilão';
      case 'neutral':
        return 'Neutro';
      default:
        return valor;
    }
  }
}

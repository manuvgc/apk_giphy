import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:apk_giphy/model/super_hero.dart';

/// Erro com mensagem já pronta para mostrar ao usuário.
class HeroException implements Exception {
  final String message;
  HeroException(this.message);

  @override
  String toString() => message;
}

class HeroService {
  // TODO: cole aqui o seu token gerado em https://superheroapi.com
  static const String _token = 'eceb199183bacb5945b3960f2bf5f48e';
  static const String _baseUrl = 'https://superheroapi.com/api';

  /// Busca heróis pelo nome (a API só entende nomes em inglês).
  Future<List<SuperHero>> buscarPorNome(String nome) async {
    final dados = await _get('search/${Uri.encodeComponent(nome)}');
    _verificarErro(dados, 'Nenhum herói encontrado para "$nome".');

    final resultados = dados['results'];
    if (resultados is! List || resultados.isEmpty) {
      throw HeroException('Nenhum herói encontrado para "$nome".');
    }
    return resultados
        .map((r) => SuperHero.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Busca um herói pelo ID (de 1 a 731).
  Future<SuperHero> buscarPorId(int id) async {
    final dados = await _get('$id');
    _verificarErro(dados, 'Herói não encontrado.');
    return SuperHero.fromJson(dados);
  }

  /// A API responde 200 mesmo com erro; o aviso vem em {"response": "error"}.
  void _verificarErro(Map<String, dynamic> dados, String msgNaoEncontrado) {
    if (dados['response'] != 'error') return;

    final erro = (dados['error'] ?? '').toString().toLowerCase();
    if (erro.contains('not found')) {
      throw HeroException(msgNaoEncontrado);
    }
    throw HeroException('A API retornou um erro: ${dados['error']}');
  }

  Future<Map<String, dynamic>> _get(String caminho) async {
    if (_token == 'SEU_TOKEN_AQUI') {
      throw HeroException(
        'Configure o token da SuperHero API em hero_service.dart.',
      );
    }

    try {
      final resposta = await http
          .get(Uri.parse('$_baseUrl/$_token/$caminho'))
          .timeout(const Duration(seconds: 10));

      if (resposta.statusCode != 200) {
        throw HeroException('Erro no servidor (código ${resposta.statusCode}).');
      }
      return json.decode(resposta.body) as Map<String, dynamic>;
    } on HeroException {
      rethrow;
    } on TimeoutException {
      throw HeroException('A consulta demorou demais. Tente novamente.');
    } on SocketException {
      throw HeroException('Sem conexão com a internet.');
    } on http.ClientException {
      throw HeroException('Sem conexão com a internet.');
    } on FormatException {
      throw HeroException('Resposta inválida da API.');
    }
  }
}

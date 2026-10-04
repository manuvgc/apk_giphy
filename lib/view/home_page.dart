import 'dart:math';

import 'package:flutter/material.dart';
import 'package:apk_giphy/model/super_hero.dart';
import 'package:apk_giphy/service/giphy_service.dart';
import 'package:apk_giphy/service/hero_service.dart';
import 'package:apk_giphy/view/giphy_page.dart';
import 'package:apk_giphy/view/hero_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final HeroService _heroService = HeroService();
  final GiphyService _giphyService = GiphyService();

  // Estado da busca de heróis
  List<SuperHero> _resultados = [];
  SuperHero? _selecionado;
  bool _carregandoHeroi = false;
  String? _erro;

  // Estado dos GIFs
  final List _gifs = [];
  int _offset = 0;
  bool _carregandoGifs = false;
  String? _erroGifs;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Validação do campo de pesquisa
  // ---------------------------------------------------------------------
  String? _validar(String texto) {
    if (texto.isEmpty) {
      return 'Digite o nome de um herói.';
    }
    if (texto.length < 2) {
      return 'Digite pelo menos 2 caracteres.';
    }
    // A API só entende nomes em inglês, sem acentos.
    if (!RegExp(r"^[a-zA-Z0-9 .\-']+$").hasMatch(texto)) {
      return 'Use apenas letras (sem acento), números, espaço, ponto ou hífen.';
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // BOTÃO 1: Buscar
  // ---------------------------------------------------------------------
  Future<void> _buscar() async {
    FocusScope.of(context).unfocus();
    final texto = _controller.text.trim();

    final erroValidacao = _validar(texto);
    if (erroValidacao != null) {
      setState(() => _erro = erroValidacao);
      return;
    }
    await _executarBusca(() => _heroService.buscarPorNome(texto));
  }

  // ---------------------------------------------------------------------
  // BOTÃO 2: Herói aleatório (IDs vão de 1 a 731)
  // ---------------------------------------------------------------------
  Future<void> _heroiAleatorio() async {
    FocusScope.of(context).unfocus();
    final id = Random().nextInt(731) + 1;
    await _executarBusca(
      () async => [await _heroService.buscarPorId(id)],
      preencherCampo: true,
    );
  }

  // ---------------------------------------------------------------------
  // BOTÃO 3: Limpar tudo
  // ---------------------------------------------------------------------
  void _limpar() {
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      _resultados = [];
      _selecionado = null;
      _erro = null;
      _erroGifs = null;
      _gifs.clear();
      _offset = 0;
    });
  }

  /// Executa uma consulta de heróis tratando carregamento e erros.
  Future<void> _executarBusca(
    Future<List<SuperHero>> Function() consulta, {
    bool preencherCampo = false,
  }) async {
    setState(() {
      _carregandoHeroi = true;
      _erro = null;
    });

    try {
      final herois = await consulta();
      if (!mounted) return;
      if (preencherCampo) _controller.text = herois.first.name;
      setState(() {
        _resultados = herois;
        _carregandoHeroi = false;
      });
      _selecionarHeroi(herois.first);
    } on HeroException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    setState(() {
      _erro = mensagem;
      _carregandoHeroi = false;
      _resultados = [];
      _selecionado = null;
      _gifs.clear();
    });
  }

  // ---------------------------------------------------------------------
  // GIFs relacionados ao herói selecionado
  // ---------------------------------------------------------------------
  void _selecionarHeroi(SuperHero heroi) {
    setState(() {
      _selecionado = heroi;
      _gifs.clear();
      _offset = 0;
      _erroGifs = null;
    });
    _carregarGifs();
  }

  Future<void> _carregarGifs() async {
    final heroi = _selecionado;
    if (heroi == null) return;

    setState(() {
      _carregandoGifs = true;
      _erroGifs = null;
    });

    try {
      final dados =
          await _giphyService.getGifs('${heroi.name} superhero', _offset);
      // Se o usuário trocou de herói enquanto carregava, ignora a resposta.
      if (!mounted || _selecionado != heroi) return;
      setState(() {
        _gifs.addAll(dados['data'] as List);
        _carregandoGifs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGifs = 'Não foi possível carregar os GIFs.';
        _carregandoGifs = false;
      });
    }
  }

  // ---------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'SuperHero Finder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildBusca(),
          Expanded(child: _buildConteudo()),
        ],
      ),
    );
  }

  Widget _buildBusca() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            decoration: const InputDecoration(
              labelText: 'Nome do herói (em inglês)',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _botao('Buscar', Icons.search,
                  _carregandoHeroi ? null : _buscar),
              _botao('Aleatório', Icons.shuffle,
                  _carregandoHeroi ? null : _heroiAleatorio),
              _botao('Limpar', Icons.clear, _carregandoHeroi ? null : _limpar),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botao(String texto, IconData icone, VoidCallback? acao) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: acao,
          icon: Icon(icone, size: 18),
          label: Text(texto, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregandoHeroi) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _erro!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
        ),
      );
    }

    final heroi = _selecionado;
    if (heroi == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pesquise um herói ou sorteie um aleatório!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Vários resultados para o mesmo nome (ex.: "batman"): escolha por chip
        if (_resultados.length > 1)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _resultados.length,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final h = _resultados[i];
                  return ChoiceChip(
                    label: Text('${h.name} #${h.id}'),
                    selected: h == heroi,
                    onSelected: (_) => _selecionarHeroi(h),
                  );
                },
              ),
            ),
          ),
        SliverToBoxAdapter(child: HeroCard(heroi: heroi)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              'GIFs de ${heroi.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildGif(_gifs[index]),
              childCount: _gifs.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildRodapeGifs()),
      ],
    );
  }

  Widget _buildGif(dynamic gif) {
    final url = gif['images']['fixed_height']['url'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GiphyPage(gif)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[900],
            child: const Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildRodapeGifs() {
    if (_carregandoGifs) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_erroGifs != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_erroGifs!, style: const TextStyle(color: Colors.redAccent)),
            TextButton(
              onPressed: _carregarGifs,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }
    if (_gifs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Nenhum GIF encontrado.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextButton.icon(
        onPressed: () {
          _offset += 25;
          _carregarGifs();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Carregar mais...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../widgets/recurso_protegido.dart';

/// Menu lateral do mapa — painel que desliza da direita sobre um fundo
/// escurecido (tocar fora fecha, mesmo gesto de um Drawer de verdade), com
/// [titulo] e botão de fechar no topo, os [itens] e o [rodape] (atribuição
/// dos dados). O que entra em [itens] fica a cargo do mapa; aqui mora só a
/// moldura e os blocos reutilizáveis ([ItemMenuToggle], [TituloSecaoMenu],
/// [SeletorTipoMapa]).
class MenuLateralMapa extends StatelessWidget {
  final bool aberto;
  final VoidCallback aoFechar;
  final String titulo;
  final String rodape;
  final List<Widget> itens;

  const MenuLateralMapa({
    super.key,
    required this.aberto,
    required this.aoFechar,
    required this.titulo,
    required this.rodape,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (aberto)
          Positioned.fill(
            child: GestureDetector(
              onTap: aoFechar,
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          top: 0,
          bottom: 0,
          right: aberto ? 0 : -320,
          width: 300,
          child: Material(
            elevation: 8,
            color: Theme.of(context).canvasColor,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  ListTile(
                    title: Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: aoFechar,
                    ),
                  ),
                  ...itens,
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      rodape,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Título de uma seção do menu ("Navegação", "Camadas").
class TituloSecaoMenu extends StatelessWidget {
  final String texto;

  const TituloSecaoMenu(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

/// Item de toggle padrão do menu — switch à direita, ícone à esquerda
/// colorido quando ativo, mesmo padrão visual pras ~10 opções do menu.
class ItemMenuToggle extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? subtitulo;
  final bool ativo;
  final VoidCallback? onTap;
  final bool carregando;

  /// Gate de plano (ver core/planos/) — quando informado e o plano ativo
  /// não liberar esse recurso, o toque mostra o card de upgrade em vez de
  /// ligar a camada. Hoje a matriz libera tudo pra todos os planos (ver
  /// matriz_entitlements.dart), então isso não muda nada visível ainda — é
  /// a aplicação do gate, não a definição de quem tem acesso.
  final RecursoAtlas? recurso;

  const ItemMenuToggle({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    required this.ativo,
    required this.onTap,
    this.carregando = false,
    this.recurso,
  });

  @override
  Widget build(BuildContext context) {
    final recurso = this.recurso;
    final bloqueado = recurso != null && !PlanoService.possui(recurso);
    return ListTile(
      leading: carregando
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icone, color: ativo ? Colors.lightBlueAccent : null),
      title: Text(titulo),
      subtitle: subtitulo == null ? null : Text(subtitulo!),
      trailing: bloqueado
          ? const Icon(Icons.lock_outline, size: 20)
          : Switch(
              value: ativo, onChanged: onTap == null ? null : (_) => onTap!()),
      onTap: bloqueado ? () => _mostrarCardUpgrade(context, recurso) : onTap,
      enabled: bloqueado || onTap != null,
      dense: true,
    );
  }

  static void _mostrarCardUpgrade(BuildContext context, RecursoAtlas recurso) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CardUpgradePlano(recurso: recurso),
        ),
      ),
    );
  }
}

/// Seletor visual do tipo de mapa base — duas opções mutuamente exclusivas
/// (nunca as duas ligadas, por isso cards de escolha em vez de dois
/// switches separados que dariam pra ligar junto por engano): a carta
/// náutica carregada (MBTiles/GeoTIFF) ou o Mapa de Ruas com as camadas do
/// OpenSeaMap por cima. Parecido com o seletor de tipo de mapa do Google
/// Maps — dois cartões lado a lado, ícone + rótulo, o escolhido com borda
/// destacada.
class SeletorTipoMapa extends StatelessWidget {
  final bool camadaRuas;
  final String tituloCarta;
  final String tituloRuas;
  final VoidCallback aoEscolherCarta;
  final VoidCallback aoEscolherRuas;

  const SeletorTipoMapa({
    super.key,
    required this.camadaRuas,
    required this.tituloCarta,
    required this.tituloRuas,
    required this.aoEscolherCarta,
    required this.aoEscolherRuas,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _CartaoTipoMapa(
              selecionado: !camadaRuas,
              icone: Icons.map_outlined,
              cor: Colors.brown,
              titulo: tituloCarta,
              onTap: aoEscolherCarta,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CartaoTipoMapa(
              selecionado: camadaRuas,
              icone: Icons.public,
              cor: Colors.blue,
              titulo: tituloRuas,
              onTap: aoEscolherRuas,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoTipoMapa extends StatelessWidget {
  final bool selecionado;
  final IconData icone;
  final Color cor;
  final String titulo;
  final VoidCallback onTap;

  const _CartaoTipoMapa({
    required this.selecionado,
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selecionado ? corPrimaria : Colors.transparent,
                width: 2.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(icone, size: 30, color: cor),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
              color: selecionado ? corPrimaria : null,
            ),
          ),
        ],
      ),
    );
  }
}

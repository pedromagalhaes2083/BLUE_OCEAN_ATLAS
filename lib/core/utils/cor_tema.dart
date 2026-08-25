import 'package:flutter/material.dart';

/// Cor pra títulos/rótulos secundários dentro de cards (ex: "VELOCIDADE DO
/// VENTO", datas, unidades) — cinza médio (`Colors.grey[600]` a `[800]`,
/// `Colors.blueGrey`) funciona bem no tema claro, mas fica difícil de ler
/// no escuro, sobretudo depois que os cards de meteorologia passaram a
/// escurecer no tema escuro (ver `BaseMeteorologyCard._corResolvida`) —
/// cinza sobre cinza escuro tem pouco contraste. No escuro, usa um cinza
/// bem claro (quase branco) em vez do tom fixo.
Color corRotulo(BuildContext context) {
  final escuro = Theme.of(context).brightness == Brightness.dark;
  return escuro ? Colors.grey.shade300 : Colors.grey.shade700;
}

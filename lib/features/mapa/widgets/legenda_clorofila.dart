// Reexporta a escala/limiares de clorofila-a — movidos pra
// `domain/models/nivel_produtividade.dart` quando o índice de
// produtividade combinado (`IndiceProdutividadeBlueOcean`) passou a
// precisar dos mesmos limiares sem depender de um arquivo de `widgets/`.
// Esse arquivo continua existindo só pra não ter que mudar o import em
// `mapa_widget.dart`.
export '../domain/models/nivel_produtividade.dart';

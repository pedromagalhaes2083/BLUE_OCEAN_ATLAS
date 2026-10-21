import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:atlas/core/gps/permissao_gps.dart';
import 'package:atlas/core/services/location_tracking_service.dart';

import 'fonte_gps_falsa.dart';

void main() {
  group('PermissaoGps.diagnosticar', () {
    test('"sempre" e "durante o uso" permitem rastrear', () async {
      final sempre = await PermissaoGps.diagnosticar(
          fonte: FonteGpsFalsa(permissao: LocationPermission.always));
      final emUso = await PermissaoGps.diagnosticar(
          fonte: FonteGpsFalsa(permissao: LocationPermission.whileInUse));
      expect(sempre.permissao, EstadoPermissaoGps.concedidaSempre);
      expect(emUso.permissao, EstadoPermissaoGps.concedidaDuranteUso);
      expect(sempre.permissao.permiteRastrear, isTrue);
      expect(emUso.permissao.permiteRastrear, isTrue);
    });

    test('negada sem permissão pra pedir: não pergunta ao usuário', () async {
      final fonte = FonteGpsFalsa(permissao: LocationPermission.denied);
      final d = await PermissaoGps.diagnosticar(fonte: fonte);
      expect(d.permissao, EstadoPermissaoGps.negada);
      expect(d.permissao.permiteRastrear, isFalse);
      expect(fonte.pedidosDePermissao, 0);
    });

    test('negada com permissão pra pedir: pergunta uma vez', () async {
      final fonte = FonteGpsFalsa(
        permissao: LocationPermission.denied,
        permissaoAposPedir: LocationPermission.whileInUse,
      );
      final d = await PermissaoGps.diagnosticar(fonte: fonte, solicitar: true);
      expect(fonte.pedidosDePermissao, 1);
      expect(d.permissao, EstadoPermissaoGps.concedidaDuranteUso);
    });

    test('negada permanentemente nunca é perguntada de novo', () async {
      final fonte = FonteGpsFalsa(permissao: LocationPermission.deniedForever);
      final d = await PermissaoGps.diagnosticar(fonte: fonte, solicitar: true);
      expect(fonte.pedidosDePermissao, 0);
      expect(d.permissao, EstadoPermissaoGps.negadaPermanentemente);
    });

    test('serviço de localização desligado é informado à parte', () async {
      final d = await PermissaoGps.diagnosticar(
          fonte: FonteGpsFalsa(servico: false));
      expect(d.servicoHabilitado, isFalse);
      expect(d.permissao.permiteRastrear, isTrue);
    });
  });

  group('LocationTrackingService.iniciarRastreamento', () {
    test('sem permissão não inicia o rastreamento', () async {
      final r = await LocationTrackingService().iniciarRastreamento(
        intervaloMinutos: 15,
        fonte: FonteGpsFalsa(permissao: LocationPermission.denied),
      );
      expect(r.status, StatusInicioRastreamento.semPermissao);
      expect(r.iniciado, isFalse);
    });

    test('negada permanentemente é distinguida (pra orientar o usuário)',
        () async {
      final r = await LocationTrackingService().iniciarRastreamento(
        intervaloMinutos: 15,
        fonte: FonteGpsFalsa(permissao: LocationPermission.deniedForever),
      );
      expect(r.status, StatusInicioRastreamento.permissaoNegadaPermanentemente);
    });

    test('inícios simultâneos compartilham uma única tentativa', () async {
      final fonte = FonteGpsFalsa(
        permissao: LocationPermission.denied,
        permissaoAposPedir: LocationPermission.denied,
      );
      final servico = LocationTrackingService();
      final a = servico.iniciarRastreamento(
          intervaloMinutos: 15, solicitarPermissao: true, fonte: fonte);
      final b = servico.iniciarRastreamento(
          intervaloMinutos: 15, solicitarPermissao: true, fonte: fonte);

      expect(identical(a, b), isTrue);
      await Future.wait([a, b]);
      // Uma tentativa só → o usuário viu o pedido de permissão uma vez.
      expect(fonte.pedidosDePermissao, 1);

      // Terminada a tentativa, uma nova chamada começa outra.
      await servico.iniciarRastreamento(
          intervaloMinutos: 15, solicitarPermissao: true, fonte: fonte);
      expect(fonte.pedidosDePermissao, 2);
    });
  });
}

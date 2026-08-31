import 'dart:async';

import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/cliente_open_meteo.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_destino.dart';
import 'package:destino_plus/features/explorar/pantalla_explorar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ServicioClimaFalso implements FuenteClimaDestino {
  _ServicioClimaFalso({
    this.resultado,
    this.error,
    this.completarManualmente = false,
  });

  final ClimaDestino? resultado;
  final ExcepcionClima? error;
  final bool completarManualmente;

  String? ultimaConsulta;
  Completer<ClimaDestino>? _completer;

  @override
  Future<ClimaDestino> consultar(String destino) {
    ultimaConsulta = destino;

    if (completarManualmente) {
      _completer = Completer<ClimaDestino>();
      return _completer!.future;
    }

    if (error != null) {
      return Future.error(error!);
    }

    return Future.value(resultado!);
  }

  void completar(ClimaDestino valor) {
    _completer?.complete(valor);
  }
}

ClimaDestino _resultado() {
  return ClimaDestino(
    consulta: 'Tarija, Bolivia',
    ubicacion: const UbicacionClima(
      id: 1,
      nombre: 'Tarija',
      latitud: -21.535,
      longitud: -64.729,
      pais: 'Bolivia',
      region: 'Tarija',
      zonaHoraria: 'America/La_Paz',
    ),
    pronostico: PronosticoClima.fromMap({
      'latitude': -21.535,
      'longitude': -64.729,
      'timezone': 'America/La_Paz',
      'current': {
        'time': '2026-08-31T12:00',
        'temperature_2m': 21.2,
        'relative_humidity_2m': 40,
        'apparent_temperature': 20.4,
        'is_day': 1,
        'weather_code': 1,
        'wind_speed_10m': 10.5,
      },
      'daily': {
        'time': ['2026-08-31', '2026-09-01'],
        'temperature_2m_max': [25.0, 24.0],
        'temperature_2m_min': [8.0, 9.0],
        'precipitation_probability_max': [5, 15],
        'weather_code': [1, 3],
      },
    }),
  );
}

Widget _app(FuenteClimaDestino servicio) {
  return MaterialApp(
    theme: TemaApp.claro,
    home: PantallaExplorar(servicioClima: servicio),
  );
}

void main() {
  testWidgets('muestra estado inicial antes de consultar', (tester) async {
    final servicio = _ServicioClimaFalso(resultado: _resultado());

    await tester.pumpWidget(_app(servicio));

    expect(
      find.text('Explora el clima de tu próximo destino'),
      findsOneWidget,
    );
    expect(find.text('Consultar clima'), findsOneWidget);
  });

  testWidgets('muestra loading mientras espera la API', (tester) async {
    final servicio = _ServicioClimaFalso(
      completarManualmente: true,
    );

    await tester.pumpWidget(_app(servicio));

    await tester.enterText(
      find.byType(TextField),
      'Tarija, Bolivia',
    );
    await tester.tap(find.text('Consultar clima'));
    await tester.pump();

    expect(
      find.text('Buscando ubicación y pronóstico...'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    servicio.completar(_resultado());
    await tester.pumpAndSettle();
  });

  testWidgets('muestra clima actual y pronóstico correcto', (tester) async {
    final servicio = _ServicioClimaFalso(resultado: _resultado());

    await tester.pumpWidget(_app(servicio));

    await tester.enterText(
      find.byType(TextField),
      'Tarija, Bolivia',
    );
    await tester.tap(find.text('Consultar clima'));
    await tester.pumpAndSettle();

    expect(servicio.ultimaConsulta, 'Tarija, Bolivia');
    expect(find.text('Tarija, Bolivia'), findsOneWidget);
    expect(find.text('21 °C'), findsOneWidget);
    expect(find.text('Mayormente despejado'), findsWidgets);
    expect(find.text('Pronóstico de 7 días'), findsOneWidget);
    expect(find.textContaining('America/La_Paz'), findsOneWidget);
  });

  testWidgets('muestra un estado de error y permite reintentar', (
    tester,
  ) async {
    final servicio = _ServicioClimaFalso(
      error: const ExcepcionClima(
        'No encontramos una ubicación para "X".',
      ),
    );

    await tester.pumpWidget(_app(servicio));

    await tester.enterText(find.byType(TextField), 'Xx');
    await tester.tap(find.text('Consultar clima'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos obtener el clima'),
      findsOneWidget,
    );
    expect(
      find.text('No encontramos una ubicación para "X".'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });
}

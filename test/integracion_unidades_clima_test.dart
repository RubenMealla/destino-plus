import 'package:destino_plus/app/preferencias/estado_unidades.dart';
import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_destino.dart';
import 'package:destino_plus/features/clima/servicios/servicio_clima_ubicacion_actual.dart';
import 'package:destino_plus/features/explorar/pantalla_explorar.dart';
import 'package:destino_plus/features/ubicacion/modelos/ubicacion_actual.dart';
import 'package:destino_plus/features/ubicacion/servicios/acciones_configuracion_ubicacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _AlmacenPreferenciasFalso implements AlmacenPreferencias {
  final Map<String, Object> datos = {};

  @override
  Future<String?> leerTexto(String clave) async {
    final valor = datos[clave];
    return valor is String ? valor : null;
  }

  @override
  Future<bool?> leerBooleano(String clave) async {
    final valor = datos[clave];
    return valor is bool ? valor : null;
  }

  @override
  Future<int?> leerEntero(String clave) async {
    final valor = datos[clave];
    return valor is int ? valor : null;
  }

  @override
  Future<void> guardarTexto(String clave, String valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> guardarBooleano(String clave, bool valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> guardarEntero(String clave, int valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> eliminar(String clave) async {
    datos.remove(clave);
  }
}


class _ClimaUbicacionFalso implements FuenteClimaUbicacionActual {
  const _ClimaUbicacionFalso(this.resultado);

  final ClimaUbicacionActual resultado;

  @override
  Future<ClimaUbicacionActual> consultar() async => resultado;
}

class _AccionesConfiguracionFalsas
    implements AccionesConfiguracionUbicacion {
  const _AccionesConfiguracionFalsas();

  @override
  Future<bool> abrirConfiguracionAplicacion() async => true;

  @override
  Future<bool> abrirConfiguracionUbicacion() async => true;
}

ClimaDestino _clima() {
  return ClimaDestino(
    consulta: 'Tarija, Bolivia',
    ubicacion: const UbicacionClima(
      id: 1,
      nombre: 'Tarija',
      latitud: -21.535,
      longitud: -64.729,
      pais: 'Bolivia',
      zonaHoraria: 'America/La_Paz',
    ),
    pronostico: PronosticoClima.fromMap({
      'latitude': -21.535,
      'longitude': -64.729,
      'timezone': 'America/La_Paz',
      'current': {
        'time': '2026-08-31T14:00',
        'temperature_2m': 20.0,
        'relative_humidity_2m': 40,
        'apparent_temperature': 18.0,
        'is_day': 1,
        'weather_code': 0,
        'wind_speed_10m': 8.0,
      },
      'daily': {
        'time': ['2026-08-31'],
        'temperature_2m_max': [25.0],
        'temperature_2m_min': [10.0],
        'precipitation_probability_max': [0],
        'weather_code': [0],
      },
    }),
  );
}

ClimaUbicacionActual _climaUbicacion() {
  return ClimaUbicacionActual(
    ubicacion: UbicacionActual(
      latitud: -21.535,
      longitud: -64.729,
      precisionMetros: 5,
      fechaHora: DateTime(2026, 8, 31, 14),
    ),
    clima: _clima(),
  );
}

void main() {
  testWidgets(
    'un resultado ya cargado cambia de Celsius a Fahrenheit sin repetir API',
    (tester) async {
      final almacen = _AlmacenPreferenciasFalso();
      final servicioPreferencias =
          ServicioPreferenciasLocales(almacen: almacen);
      final unidades = EstadoUnidades(
        servicio: servicioPreferencias,
      );
      await unidades.cargar();

      var consultas = 0;
      final climaBase = _clima();

      final servicioClima = _FuenteClimaContador(
        onConsultar: () {
          consultas += 1;
          return climaBase;
        },
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<EstadoUnidades>.value(
          value: unidades,
          child: MaterialApp(
            theme: TemaApp.claro,
            home: PantallaExplorar(
              servicioClima: servicioClima,
              servicioClimaUbicacion:
                  _ClimaUbicacionFalso(_climaUbicacion()),
              accionesConfiguracionUbicacion:
                  const _AccionesConfiguracionFalsas(),
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'Tarija, Bolivia',
      );
      await tester.tap(find.text('Consultar clima'));
      await tester.pumpAndSettle();

      expect(consultas, 1);
      expect(find.text('20 °C'), findsOneWidget);
      expect(find.text('18 °C'), findsOneWidget);

      await unidades.cambiarTemperatura(
        UnidadTemperatura.fahrenheit,
      );
      await tester.pumpAndSettle();

      expect(consultas, 1);
      expect(find.text('68 °F'), findsOneWidget);
      expect(find.text('64 °F'), findsOneWidget);
      expect(find.textContaining('77° / 50° F'), findsOneWidget);
      expect(
        await servicioPreferencias.leerUnidadTemperatura(),
        'fahrenheit',
      );
    },
  );
}

class _FuenteClimaContador implements FuenteClimaDestino {
  const _FuenteClimaContador({
    required this.onConsultar,
  });

  final ClimaDestino Function() onConsultar;

  @override
  Future<ClimaDestino> consultar(String destino) async {
    return onConsultar();
  }
}

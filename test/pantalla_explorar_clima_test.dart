import 'dart:async';

import 'package:destino_plus/app/preferencias/estado_unidades.dart';
import 'package:destino_plus/app/preferencias/servicio_preferencias_locales.dart';
import 'package:destino_plus/app/theme/tema_app.dart';
import 'package:destino_plus/features/clima/modelos/pronostico_clima.dart';
import 'package:destino_plus/features/clima/modelos/ubicacion_clima.dart';
import 'package:destino_plus/features/clima/servicios/cliente_open_meteo.dart';
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

class _ServicioUbicacionFalso implements FuenteClimaUbicacionActual {
  _ServicioUbicacionFalso({
    this.resultado,
    this.error,
  });

  final ClimaUbicacionActual? resultado;
  final Object? error;
  bool consultado = false;

  @override
  Future<ClimaUbicacionActual> consultar() async {
    consultado = true;

    if (error != null) {
      return Future<ClimaUbicacionActual>.error(error!);
    }

    return resultado!;
  }
}

class _AccionesUbicacionFalsas
    implements AccionesConfiguracionUbicacion {
  bool configuracionAplicacionAbierta = false;
  bool configuracionUbicacionAbierta = false;

  @override
  Future<bool> abrirConfiguracionAplicacion() async {
    configuracionAplicacionAbierta = true;
    return true;
  }

  @override
  Future<bool> abrirConfiguracionUbicacion() async {
    configuracionUbicacionAbierta = true;
    return true;
  }
}

ClimaDestino _resultado({
  String nombre = 'Tarija, Bolivia',
}) {
  return ClimaDestino(
    consulta: nombre,
    ubicacion: UbicacionClima(
      id: 1,
      nombre: nombre,
      latitud: -21.535,
      longitud: -64.729,
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

ClimaUbicacionActual _resultadoUbicacionActual() {
  return ClimaUbicacionActual(
    ubicacion: UbicacionActual(
      latitud: -21.535,
      longitud: -64.729,
      precisionMetros: 6.5,
      fechaHora: DateTime(2026, 8, 31, 12),
    ),
    clima: _resultado(nombre: 'Mi ubicación actual'),
  );
}

Future<EstadoUnidades> _unidades({
  UnidadTemperatura unidad = UnidadTemperatura.celsius,
}) async {
  final estado = EstadoUnidades(
    servicio: ServicioPreferenciasLocales(
      almacen: _AlmacenPreferenciasFalso(),
    ),
  );
  await estado.cargar();

  if (unidad != UnidadTemperatura.celsius) {
    await estado.cambiarTemperatura(unidad);
  }

  return estado;
}

Widget _app({
  required FuenteClimaDestino servicio,
  required EstadoUnidades unidades,
  FuenteClimaUbicacionActual? servicioUbicacion,
  AccionesConfiguracionUbicacion? accionesUbicacion,
}) {
  return ChangeNotifierProvider<EstadoUnidades>.value(
    value: unidades,
    child: MaterialApp(
      theme: TemaApp.claro,
      home: PantallaExplorar(
        servicioClima: servicio,
        servicioClimaUbicacion:
            servicioUbicacion ??
            _ServicioUbicacionFalso(
              resultado: _resultadoUbicacionActual(),
            ),
        accionesConfiguracionUbicacion:
            accionesUbicacion ?? _AccionesUbicacionFalsas(),
      ),
    ),
  );
}

void main() {
  testWidgets('muestra estado inicial antes de consultar', (tester) async {
    final servicio = _ServicioClimaFalso(resultado: _resultado());

    await tester.pumpWidget(
      _app(
        servicio: servicio,
        unidades: await _unidades(),
      ),
    );

    expect(
      find.text('Explora el clima de tu próximo destino'),
      findsOneWidget,
    );
    expect(find.text('Consultar clima'), findsOneWidget);
    expect(find.text('Usar mi ubicación'), findsOneWidget);
  });

  testWidgets('muestra loading mientras espera la API', (tester) async {
    final servicio = _ServicioClimaFalso(
      completarManualmente: true,
    );

    await tester.pumpWidget(
      _app(
        servicio: servicio,
        unidades: await _unidades(),
      ),
    );

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

  testWidgets('muestra clima actual y pronóstico correcto en Celsius', (
    tester,
  ) async {
    final servicio = _ServicioClimaFalso(resultado: _resultado());

    await tester.pumpWidget(
      _app(
        servicio: servicio,
        unidades: await _unidades(),
      ),
    );

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

  testWidgets('presenta el clima en Fahrenheit cuando está configurado', (
    tester,
  ) async {
    final servicio = _ServicioClimaFalso(resultado: _resultado());

    await tester.pumpWidget(
      _app(
        servicio: servicio,
        unidades: await _unidades(
          unidad: UnidadTemperatura.fahrenheit,
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'Tarija, Bolivia',
    );
    await tester.tap(find.text('Consultar clima'));
    await tester.pumpAndSettle();

    // 21.2 °C equivale aproximadamente a 70 °F.
    expect(find.text('70 °F'), findsOneWidget);
    expect(find.textContaining('77° / 46° F'), findsOneWidget);
  });

  testWidgets('usa ubicación actual y muestra su precisión', (tester) async {
    final climaTexto = _ServicioClimaFalso(resultado: _resultado());
    final ubicacion = _ServicioUbicacionFalso(
      resultado: _resultadoUbicacionActual(),
    );

    await tester.pumpWidget(
      _app(
        servicio: climaTexto,
        unidades: await _unidades(),
        servicioUbicacion: ubicacion,
      ),
    );

    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    expect(ubicacion.consultado, isTrue);
    expect(find.text('Mi ubicación actual'), findsOneWidget);
    expect(
      find.textContaining('precisión aproximada de 6.5 m'),
      findsOneWidget,
    );
    expect(find.text('21 °C'), findsOneWidget);
  });

  testWidgets('error manual mantiene el reintento de búsqueda', (
    tester,
  ) async {
    final servicio = _ServicioClimaFalso(
      error: const ExcepcionClima(
        'No encontramos una ubicación para "X".',
      ),
    );

    await tester.pumpWidget(
      _app(
        servicio: servicio,
        unidades: await _unidades(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Xx');
    await tester.tap(find.text('Consultar clima'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos obtener el clima'),
      findsOneWidget,
    );
    expect(find.text('Reintentar búsqueda'), findsOneWidget);
  });

  testWidgets('permiso bloqueado ofrece abrir configuración de la app', (
    tester,
  ) async {
    final acciones = _AccionesUbicacionFalsas();
    final ubicacion = _ServicioUbicacionFalso(
      error: const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.permisoDenegadoPermanentemente,
        mensaje:
            'El permiso de ubicación está bloqueado.',
      ),
    );

    await tester.pumpWidget(
      _app(
        servicio: _ServicioClimaFalso(resultado: _resultado()),
        unidades: await _unidades(),
        servicioUbicacion: ubicacion,
        accionesUbicacion: acciones,
      ),
    );

    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    expect(
      find.text('No pudimos usar tu ubicación'),
      findsOneWidget,
    );
    expect(
      find.text('Abrir configuración de la app'),
      findsOneWidget,
    );

    await tester.tap(find.text('Abrir configuración de la app'));
    await tester.pump();

    expect(acciones.configuracionAplicacionAbierta, isTrue);
  });

  testWidgets('ubicación desactivada ofrece abrir ajustes de ubicación', (
    tester,
  ) async {
    final acciones = _AccionesUbicacionFalsas();
    final ubicacion = _ServicioUbicacionFalso(
      error: const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.servicioDeshabilitado,
        mensaje:
            'La ubicación del dispositivo está desactivada.',
      ),
    );

    await tester.pumpWidget(
      _app(
        servicio: _ServicioClimaFalso(resultado: _resultado()),
        unidades: await _unidades(),
        servicioUbicacion: ubicacion,
        accionesUbicacion: acciones,
      ),
    );

    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    expect(
      find.text('Abrir configuración de ubicación'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('Abrir configuración de ubicación'),
    );
    await tester.pump();

    expect(acciones.configuracionUbicacionAbierta, isTrue);
  });

  testWidgets('permiso denegado permite volver a solicitarlo', (
    tester,
  ) async {
    final ubicacion = _ServicioUbicacionFalso(
      error: const ExcepcionUbicacion(
        tipo: TipoErrorUbicacion.permisoDenegado,
        mensaje:
            'Necesitamos permiso de ubicación para continuar.',
      ),
    );

    await tester.pumpWidget(
      _app(
        servicio: _ServicioClimaFalso(resultado: _resultado()),
        unidades: await _unidades(),
        servicioUbicacion: ubicacion,
      ),
    );

    await tester.tap(find.text('Usar mi ubicación'));
    await tester.pumpAndSettle();

    expect(find.text('Reintentar permiso'), findsOneWidget);
  });
}

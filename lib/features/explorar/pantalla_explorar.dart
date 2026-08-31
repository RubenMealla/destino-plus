import 'package:flutter/material.dart';

import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/boton_accion.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/estado_vacio.dart';
import '../../shared/widgets/tarjeta_informativa.dart';
import '../clima/modelos/pronostico_clima.dart';
import '../clima/presentacion/clima_visual.dart';
import '../clima/servicios/cliente_open_meteo.dart';
import '../clima/servicios/servicio_clima_destino.dart';

/// Consulta clima real de un destino mediante Open-Meteo.
class PantallaExplorar extends StatefulWidget {
  const PantallaExplorar({
    super.key,
    this.servicioClima,
  });

  final FuenteClimaDestino? servicioClima;

  @override
  State<PantallaExplorar> createState() => _PantallaExplorarState();
}

class _PantallaExplorarState extends State<PantallaExplorar> {
  final _destinoController = TextEditingController();

  ClimaDestino? _resultado;
  String? _error;
  bool _cargando = false;
  bool _consultaRealizada = false;

  FuenteClimaDestino get _servicio =>
      widget.servicioClima ?? ServicioClimaDestino();

  @override
  void dispose() {
    _destinoController.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    final destino = _destinoController.text.trim();

    FocusScope.of(context).unfocus();

    if (destino.length < 2 || _cargando) {
      setState(() {
        _consultaRealizada = true;
        _resultado = null;
        _error = 'Escribe un destino para consultar el clima.';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _consultaRealizada = true;
      _resultado = null;
      _error = null;
    });

    try {
      final resultado = await _servicio.consultar(destino);

      if (!mounted) {
        return;
      }

      setState(() {
        _resultado = resultado;
      });
    } on ExcepcionClima catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.mensaje;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'No fue posible consultar el clima en este momento.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
      ),
      body: SingleChildScrollView(
        child: ContenidoAdaptable(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Clima del destino',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: DimensionesApp.espacio8),
              Text(
                'Consulta condiciones actuales y el pronóstico de los '
                'próximos días antes de organizar tu viaje.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: DimensionesApp.espacio24),
              TextField(
                controller: _destinoController,
                enabled: !_cargando,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _consultar(),
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  hintText: 'Ej. Tarija, Bolivia',
                  prefixIcon: Icon(Icons.travel_explore_outlined),
                ),
              ),
              const SizedBox(height: DimensionesApp.espacio12),
              BotonAccion(
                texto: _cargando ? 'Consultando clima...' : 'Consultar clima',
                icono: _cargando ? null : Icons.cloud_outlined,
                onPressed: _cargando ? null : _consultar,
              ),
              const SizedBox(height: DimensionesApp.espacio24),
              if (_cargando)
                const _EstadoCargando()
              else if (_error != null)
                EstadoVacio(
                  icono: Icons.cloud_off_outlined,
                  titulo: 'No pudimos obtener el clima',
                  mensaje: _error!,
                  accion: BotonAccion(
                    texto: 'Reintentar',
                    icono: Icons.refresh_rounded,
                    onPressed: _consultar,
                  ),
                )
              else if (_resultado != null)
                _ResultadoClima(resultado: _resultado!)
              else if (!_consultaRealizada)
                const EstadoVacio(
                  icono: Icons.public_outlined,
                  titulo: 'Explora el clima de tu próximo destino',
                  mensaje:
                      'Escribe una ciudad o destino para consultar datos '
                      'meteorológicos reales mediante Open-Meteo.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoCargando extends StatelessWidget {
  const _EstadoCargando();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: DimensionesApp.espacio32,
      ),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: DimensionesApp.espacio16),
          Text(
            'Buscando ubicación y pronóstico...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ResultadoClima extends StatelessWidget {
  const _ResultadoClima({
    required this.resultado,
  });

  final ClimaDestino resultado;

  @override
  Widget build(BuildContext context) {
    final actual = resultado.pronostico.actual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TarjetaInformativa(
          icono: ClimaVisual.icono(
            actual.codigoClima,
            esDeDia: actual.esDeDia,
          ),
          titulo: resultado.ubicacion.nombreCompleto,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_temperatura(actual.temperatura)} °C',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: DimensionesApp.espacio4),
              Text(
                ClimaVisual.descripcion(actual.codigoClima),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: DimensionesApp.espacio16),
              _DatoClima(
                icono: Icons.thermostat_outlined,
                etiqueta: 'Sensación',
                valor:
                    '${_temperatura(actual.temperaturaAparente)} °C',
              ),
              const SizedBox(height: DimensionesApp.espacio8),
              _DatoClima(
                icono: Icons.water_drop_outlined,
                etiqueta: 'Humedad',
                valor: '${actual.humedadRelativa} %',
              ),
              const SizedBox(height: DimensionesApp.espacio8),
              _DatoClima(
                icono: Icons.air_rounded,
                etiqueta: 'Viento',
                valor:
                    '${_numero(actual.velocidadViento)} km/h',
              ),
            ],
          ),
        ),
        const SizedBox(height: DimensionesApp.espacio24),
        Text(
          'Pronóstico de 7 días',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: DimensionesApp.espacio12),
        if (resultado.pronostico.dias.isEmpty)
          const EstadoVacio(
            icono: Icons.event_busy_outlined,
            titulo: 'Pronóstico diario no disponible',
            mensaje:
                'Open-Meteo no devolvió datos diarios para esta ubicación.',
          )
        else
          ...resultado.pronostico.dias.map(
            (dia) => Padding(
              padding: const EdgeInsets.only(
                bottom: DimensionesApp.espacio12,
              ),
              child: _TarjetaPronosticoDia(dia: dia),
            ),
          ),
        const SizedBox(height: DimensionesApp.espacio8),
        Text(
          'Fuente meteorológica: Open-Meteo · '
          'Zona horaria: ${resultado.pronostico.zonaHoraria}',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static String _temperatura(double valor) {
    return valor.round().toString();
  }

  static String _numero(double valor) {
    if (valor == valor.roundToDouble()) {
      return valor.round().toString();
    }

    return valor.toStringAsFixed(1);
  }
}

class _TarjetaPronosticoDia extends StatelessWidget {
  const _TarjetaPronosticoDia({
    required this.dia,
  });

  final PronosticoDiario dia;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DimensionesApp.espacio16),
        child: Row(
          children: [
            Icon(
              ClimaVisual.icono(dia.codigoClima),
              size: 30,
            ),
            const SizedBox(width: DimensionesApp.espacio12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fechaCorta(dia.fecha),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: DimensionesApp.espacio4),
                  Text(
                    ClimaVisual.descripcion(dia.codigoClima),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: DimensionesApp.espacio8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${dia.temperaturaMaxima.round()}° / '
                  '${dia.temperaturaMinima.round()}°',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: DimensionesApp.espacio4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text('${dia.probabilidadPrecipitacion}%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fechaCorta(DateTime fecha) {
    const diasSemana = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];

    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    return '${diasSemana[fecha.weekday - 1]}, '
        '${fecha.day} ${meses[fecha.month - 1]}';
  }
}

class _DatoClima extends StatelessWidget {
  const _DatoClima({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 18),
        const SizedBox(width: DimensionesApp.espacio8),
        Expanded(child: Text(etiqueta)),
        Text(
          valor,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

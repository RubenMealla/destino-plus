import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/preferencias/estado_unidades.dart';
import '../../app/router/rutas_app.dart';
import '../../app/theme/dimensiones_app.dart';
import '../../shared/widgets/contenido_adaptable.dart';
import '../../shared/widgets/encabezado_seccion.dart';
import '../../shared/widgets/marca_destino_plus.dart';
import '../clima/estado/estado_climas_recientes.dart';
import '../clima/modelos/clima_reciente.dart';
import '../clima/presentacion/clima_visual.dart';
import '../viajes/modelos/viaje.dart';
import '../viajes/servicios/repositorio_viajes.dart';
import '../viajes/widgets/tarjeta_viaje.dart';

/// Panel principal con información real y resumida del usuario.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key, this.repositorioViajes});

  final FuenteViajes? repositorioViajes;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late Future<List<Viaje>> _cargaViajes;

  FuenteViajes get _repositorio =>
      widget.repositorioViajes ?? RepositorioViajes.instancia;

  @override
  void initState() {
    super.initState();
    _recargarViajes();
  }

  void _recargarViajes() {
    _cargaViajes = _repositorio.listar();
  }

  Future<void> _actualizar() async {
    setState(_recargarViajes);
    await _cargaViajes;
  }

  List<Viaje> _proximos(List<Viaje> viajes) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    final resultado =
        viajes.where((viaje) => !viaje.fechaFin.isBefore(hoy)).toList()
          ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

    return resultado.take(3).toList(growable: false);
  }

  Future<void> _abrirViaje(Viaje viaje) async {
    final cambio = await context.push<bool>(RutasApp.detalleDeViaje(viaje.id));

    if (cambio == true && mounted) {
      await _actualizar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Actualizar inicio',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _actualizar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ContenidoAdaptable(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MarcaDestinoPlus(mostrarLema: false),
                const SizedBox(height: DimensionesApp.espacio24),
                Text(
                  'Planifica tu próximo viaje',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: DimensionesApp.espacio8),
                Text(
                  'Revisa tus próximos viajes y las últimas consultas '
                  'meteorológicas desde un solo lugar.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: DimensionesApp.espacio32),
                _SeccionViajes(
                  carga: _cargaViajes,
                  filtrar: _proximos,
                  onReintentar: _actualizar,
                  onAbrirViaje: _abrirViaje,
                ),
                const SizedBox(height: DimensionesApp.espacio32),
                const _SeccionClimasRecientes(),
                const SizedBox(height: DimensionesApp.espacio24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeccionViajes extends StatelessWidget {
  const _SeccionViajes({
    required this.carga,
    required this.filtrar,
    required this.onReintentar,
    required this.onAbrirViaje,
  });

  final Future<List<Viaje>> carga;
  final List<Viaje> Function(List<Viaje>) filtrar;
  final Future<void> Function() onReintentar;
  final Future<void> Function(Viaje) onAbrirViaje;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Viaje>>(
      future: carga,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _TarjetaEstadoInicio(
            icono: Icons.luggage_outlined,
            titulo: 'Cargando tus viajes...',
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          final mensaje = snapshot.error is ExcepcionViajes
              ? (snapshot.error! as ExcepcionViajes).mensaje
              : 'No fue posible cargar tus viajes.';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const EncabezadoSeccion(
                titulo: 'Próximos viajes',
                subtitulo: 'Tus viajes activos y futuros.',
              ),
              const SizedBox(height: DimensionesApp.espacio16),
              _TarjetaEstadoInicio(
                icono: Icons.cloud_off_outlined,
                titulo: 'No pudimos cargar tus viajes',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mensaje),
                    const SizedBox(height: DimensionesApp.espacio12),
                    OutlinedButton.icon(
                      onPressed: onReintentar,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final viajes = filtrar(snapshot.data ?? const <Viaje>[]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: EncabezadoSeccion(
                    titulo: 'Próximos viajes',
                    subtitulo: 'Tus viajes activos y futuros.',
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(RutasApp.viajes),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: DimensionesApp.espacio16),
            if (viajes.isEmpty)
              _TarjetaEstadoInicio(
                icono: Icons.luggage_outlined,
                titulo: 'Aún no tienes viajes próximos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crea un viaje para comenzar a organizar tu destino, '
                      'fechas y actividades.',
                    ),
                    const SizedBox(height: DimensionesApp.espacio12),
                    FilledButton.icon(
                      onPressed: () => context.push(RutasApp.nuevoViaje),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Nuevo viaje'),
                    ),
                  ],
                ),
              )
            else
              for (var i = 0; i < viajes.length; i++) ...[
                TarjetaViaje(
                  viaje: viajes[i],
                  onTap: () => onAbrirViaje(viajes[i]),
                ),
                if (i != viajes.length - 1)
                  const SizedBox(height: DimensionesApp.espacio12),
              ],
          ],
        );
      },
    );
  }
}

class _SeccionClimasRecientes extends StatelessWidget {
  const _SeccionClimasRecientes();

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoClimasRecientes>();
    final consultas = estado.consultas;
    final unidad = context.watch<EstadoUnidades>().temperatura;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: EncabezadoSeccion(
                titulo: 'Climas recientes',
                subtitulo: 'Tus últimas consultas meteorológicas.',
              ),
            ),
            TextButton(
              onPressed: () => context.go(RutasApp.explorar),
              child: const Text('Explorar'),
            ),
          ],
        ),
        const SizedBox(height: DimensionesApp.espacio16),
        if (!estado.cargado)
          const _TarjetaEstadoInicio(
            icono: Icons.cloud_outlined,
            titulo: 'Cargando clima reciente...',
            child: LinearProgressIndicator(),
          )
        else if (consultas.isEmpty)
          _TarjetaEstadoInicio(
            icono: Icons.travel_explore_outlined,
            titulo: 'Consulta el clima de un destino',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuando consultes una ubicación en Explorar, aparecerá '
                  'aquí y seguirá disponible al volver a abrir Destino+.',
                ),
                const SizedBox(height: DimensionesApp.espacio12),
                OutlinedButton.icon(
                  onPressed: () => context.go(RutasApp.explorar),
                  icon: const Icon(Icons.cloud_outlined),
                  label: const Text('Consultar clima'),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < consultas.length; i++) ...[
            _TarjetaClimaReciente(
              clima: consultas[i],
              unidad: unidad,
              onTap: () => context.go(RutasApp.explorar),
            ),
            if (i != consultas.length - 1)
              const SizedBox(height: DimensionesApp.espacio12),
          ],
      ],
    );
  }
}

class _TarjetaClimaReciente extends StatelessWidget {
  const _TarjetaClimaReciente({
    required this.clima,
    required this.unidad,
    required this.onTap,
  });

  final ClimaReciente clima;
  final UnidadTemperatura unidad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final temperatura = unidad.convertirDesdeCelsius(clima.temperaturaCelsius);
    final sensacion = unidad.convertirDesdeCelsius(
      clima.temperaturaAparenteCelsius,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DimensionesApp.espacio16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(
                    DimensionesApp.radioPequeno,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  ClimaVisual.icono(clima.codigoClima, esDeDia: clima.esDeDia),
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: DimensionesApp.espacio12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clima.ubicacion, style: textTheme.titleMedium),
                    const SizedBox(height: DimensionesApp.espacio4),
                    Text(
                      '${_numero(temperatura)} ${unidad.simbolo} · '
                      '${ClimaVisual.descripcion(clima.codigoClima)}',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: DimensionesApp.espacio8),
                    Wrap(
                      spacing: DimensionesApp.espacio16,
                      runSpacing: DimensionesApp.espacio4,
                      children: [
                        Text(
                          'Sensación ${_numero(sensacion)} ${unidad.simbolo}',
                          style: textTheme.bodySmall,
                        ),
                        Text(
                          'Humedad ${clima.humedadRelativa} %',
                          style: textTheme.bodySmall,
                        ),
                        Text(
                          'Viento ${_numero(clima.velocidadViento)} km/h',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: DimensionesApp.espacio8),
                    Text(
                      _actualizado(clima.consultadoEn),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DimensionesApp.espacio8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  static String _numero(double valor) {
    final redondeado = valor.roundToDouble();
    return valor == redondeado
        ? redondeado.toInt().toString()
        : valor.toStringAsFixed(1);
  }

  static String _actualizado(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);

    if (diferencia.isNegative || diferencia.inMinutes < 1) {
      return 'Actualizado ahora';
    }
    if (diferencia.inMinutes < 60) {
      return 'Actualizado hace ${diferencia.inMinutes} min';
    }
    if (diferencia.inHours < 24) {
      final horas = diferencia.inHours;
      return 'Actualizado hace $horas ${horas == 1 ? 'hora' : 'horas'}';
    }
    final dias = diferencia.inDays;
    return 'Actualizado hace $dias ${dias == 1 ? 'día' : 'días'}';
  }
}

class _TarjetaEstadoInicio extends StatelessWidget {
  const _TarjetaEstadoInicio({
    required this.icono,
    required this.titulo,
    required this.child,
  });

  final IconData icono;
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DimensionesApp.espacio16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: colorScheme.secondary),
                const SizedBox(width: DimensionesApp.espacio12),
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DimensionesApp.espacio12),
            child,
          ],
        ),
      ),
    );
  }
}

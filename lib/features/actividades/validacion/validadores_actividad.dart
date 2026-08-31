import '../../viajes/modelos/viaje.dart';

/// Reglas compartidas para las actividades del itinerario.
abstract final class ValidadoresActividad {
  static const int tituloMinimo = 2;
  static const int tituloMaximo = 120;
  static const int lugarMaximo = 160;
  static const int notasMaximas = 1000;

  const ValidadoresActividad._();

  static String? titulo(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.length < tituloMinimo) {
      return 'El título debe tener al menos $tituloMinimo caracteres.';
    }

    if (texto.length > tituloMaximo) {
      return 'El título no puede superar $tituloMaximo caracteres.';
    }

    return null;
  }

  static String? lugar(String? valor) {
    if ((valor?.trim().length ?? 0) > lugarMaximo) {
      return 'El lugar no puede superar los $lugarMaximo caracteres.';
    }

    return null;
  }

  static String? notas(String? valor) {
    if ((valor?.trim().length ?? 0) > notasMaximas) {
      return 'Las notas no pueden superar los $notasMaximas caracteres.';
    }

    return null;
  }

  static String? fecha(String? valor) {
    if (parsearFecha(valor) == null) {
      return 'Usa el formato DD/MM/AAAA.';
    }

    return null;
  }

  static String? hora(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return null;
    }

    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(texto)) {
      return 'Usa el formato HH:mm.';
    }

    return null;
  }

  static String? fechaDentroDelViaje(
    DateTime fecha,
    Viaje viaje,
  ) {
    final actividad = DateTime(fecha.year, fecha.month, fecha.day);
    final inicio = DateTime(
      viaje.fechaInicio.year,
      viaje.fechaInicio.month,
      viaje.fechaInicio.day,
    );
    final fin = DateTime(
      viaje.fechaFin.year,
      viaje.fechaFin.month,
      viaje.fechaFin.day,
    );

    if (actividad.isBefore(inicio) || actividad.isAfter(fin)) {
      return 'La actividad debe estar entre ${formatearFecha(inicio)} y '
          '${formatearFecha(fin)}.';
    }

    return null;
  }

  static DateTime? parsearFecha(String? valor) {
    final partes = (valor ?? '').trim().split('/');

    if (partes.length != 3) {
      return null;
    }

    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final anio = int.tryParse(partes[2]);

    if (dia == null || mes == null || anio == null) {
      return null;
    }

    if (anio < 2000 || anio > 2100 || mes < 1 || mes > 12) {
      return null;
    }

    final fecha = DateTime(anio, mes, dia);

    if (fecha.year != anio || fecha.month != mes || fecha.day != dia) {
      return null;
    }

    return fecha;
  }

  static String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}

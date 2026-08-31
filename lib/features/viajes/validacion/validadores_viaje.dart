/// Reglas de validación compartidas por el formulario y el repositorio.
abstract final class ValidadoresViaje {
  static const int tituloMinimo = 2;
  static const int tituloMaximo = 100;
  static const int destinoMinimo = 2;
  static const int destinoMaximo = 120;
  static const int descripcionMaxima = 1000;

  const ValidadoresViaje._();

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

  static String? destino(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.length < destinoMinimo) {
      return 'El destino debe tener al menos $destinoMinimo caracteres.';
    }

    if (texto.length > destinoMaximo) {
      return 'El destino no puede superar $destinoMaximo caracteres.';
    }

    return null;
  }

  static String? descripcion(String? valor) {
    if ((valor?.trim().length ?? 0) > descripcionMaxima) {
      return 'La descripción no puede superar $descripcionMaxima caracteres.';
    }

    return null;
  }

  static String? fecha(String? valor) {
    if (parsearFecha(valor) == null) {
      return 'Usa el formato DD/MM/AAAA.';
    }

    return null;
  }

  static String? rangoFechas(DateTime inicio, DateTime fin) {
    final fechaInicio = DateTime(inicio.year, inicio.month, inicio.day);
    final fechaFin = DateTime(fin.year, fin.month, fin.day);

    if (fechaFin.isBefore(fechaInicio)) {
      return 'La fecha de fin no puede ser anterior a la fecha de inicio.';
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
}

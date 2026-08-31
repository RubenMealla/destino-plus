import 'package:flutter/material.dart';

/// Traduce códigos meteorológicos WMO de Open-Meteo a texto e iconos.
abstract final class ClimaVisual {
  const ClimaVisual._();

  static String descripcion(int codigo) {
    if (codigo == 0) return 'Despejado';
    if (codigo == 1) return 'Mayormente despejado';
    if (codigo == 2) return 'Parcialmente nublado';
    if (codigo == 3) return 'Nublado';
    if (codigo == 45 || codigo == 48) return 'Niebla';
    if (codigo == 51 || codigo == 53 || codigo == 55) {
      return 'Llovizna';
    }
    if (codigo == 56 || codigo == 57) return 'Llovizna helada';
    if (codigo == 61 || codigo == 63 || codigo == 65) return 'Lluvia';
    if (codigo == 66 || codigo == 67) return 'Lluvia helada';
    if (codigo == 71 || codigo == 73 || codigo == 75 || codigo == 77) {
      return 'Nieve';
    }
    if (codigo == 80 || codigo == 81 || codigo == 82) {
      return 'Chubascos';
    }
    if (codigo == 85 || codigo == 86) return 'Chubascos de nieve';
    if (codigo == 95) return 'Tormenta';
    if (codigo == 96 || codigo == 99) return 'Tormenta con granizo';

    return 'Condiciones variables';
  }

  static IconData icono(
    int codigo, {
    bool esDeDia = true,
  }) {
    if (codigo == 0) {
      return esDeDia
          ? Icons.wb_sunny_outlined
          : Icons.nightlight_outlined;
    }

    if (codigo == 1 || codigo == 2) {
      return esDeDia
          ? Icons.wb_cloudy_outlined
          : Icons.nights_stay_outlined;
    }

    if (codigo == 3) return Icons.cloud_outlined;
    if (codigo == 45 || codigo == 48) return Icons.foggy;

    if ({
      51,
      53,
      55,
      56,
      57,
      61,
      63,
      65,
      66,
      67,
      80,
      81,
      82,
    }.contains(codigo)) {
      return Icons.water_drop_outlined;
    }

    if ({71, 73, 75, 77, 85, 86}.contains(codigo)) {
      return Icons.ac_unit_outlined;
    }

    if ({95, 96, 99}.contains(codigo)) {
      return Icons.thunderstorm_outlined;
    }

    return Icons.cloud_queue_outlined;
  }
}

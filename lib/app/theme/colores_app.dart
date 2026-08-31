import 'package:flutter/material.dart';

/// Paleta visual central de Destino+.
///
/// Los colores se concentran en este archivo para evitar valores dispersos
/// por las pantallas y facilitar futuros cambios de identidad visual.
abstract final class ColoresApp {
  // Identidad principal.
  static const Color azulDestino = Color(0xFF145A78);
  static const Color turquesaRuta = Color(0xFF1E8C82);
  static const Color arenaViaje = Color(0xFFF2E5D5);
  static const Color coralAcento = Color(0xFFE77A5B);

  // Superficies claras.
  static const Color fondoClaro = Color(0xFFF7F9FA);
  static const Color superficieClara = Color(0xFFFFFFFF);
  static const Color textoPrincipalClaro = Color(0xFF1B252B);
  static const Color textoSecundarioClaro = Color(0xFF5D6A70);
  static const Color bordeClaro = Color(0xFFD8E0E4);

  // Superficies oscuras.
  static const Color fondoOscuro = Color(0xFF101719);
  static const Color superficieOscura = Color(0xFF172125);
  static const Color textoPrincipalOscuro = Color(0xFFF1F5F6);
  static const Color textoSecundarioOscuro = Color(0xFFB7C3C7);
  static const Color bordeOscuro = Color(0xFF334247);

  // Estados.
  static const Color exito = Color(0xFF2D8A63);
  static const Color advertencia = Color(0xFFD8922B);
  static const Color error = Color(0xFFB94A48);

  const ColoresApp._();
}

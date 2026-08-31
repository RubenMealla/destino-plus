import 'package:flutter/material.dart';

import 'colores_app.dart';
import 'dimensiones_app.dart';

/// Configuración global de Material 3 para Destino+.
abstract final class TemaApp {
  static final ThemeData claro = _crearTema(Brightness.light);
  static final ThemeData oscuro = _crearTema(Brightness.dark);

  static ThemeData _crearTema(Brightness brightness) {
    final bool esOscuro = brightness == Brightness.dark;

    final ColorScheme esquemaBase = ColorScheme.fromSeed(
      seedColor: ColoresApp.azulDestino,
      brightness: brightness,
    );

    final ColorScheme esquema = esquemaBase.copyWith(
      primary: ColoresApp.azulDestino,
      secondary: ColoresApp.turquesaRuta,
      tertiary: ColoresApp.coralAcento,
      error: ColoresApp.error,
      surface: esOscuro
          ? ColoresApp.superficieOscura
          : ColoresApp.superficieClara,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: esquema,
    );

    final Color colorTexto = esOscuro
        ? ColoresApp.textoPrincipalOscuro
        : ColoresApp.textoPrincipalClaro;

    final Color colorTextoSecundario = esOscuro
        ? ColoresApp.textoSecundarioOscuro
        : ColoresApp.textoSecundarioClaro;

    final Color colorBorde =
        esOscuro ? ColoresApp.bordeOscuro : ColoresApp.bordeClaro;

    return base.copyWith(
      scaffoldBackgroundColor:
          esOscuro ? ColoresApp.fondoOscuro : ColoresApp.fondoClaro,
      textTheme: _crearTipografia(
        base.textTheme,
        colorTexto,
        colorTextoSecundario,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorTexto,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: colorTexto,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: esOscuro
            ? ColoresApp.superficieOscura
            : ColoresApp.superficieClara,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          side: BorderSide(color: colorBorde),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esOscuro
            ? ColoresApp.superficieOscura
            : ColoresApp.superficieClara,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DimensionesApp.espacio16,
          vertical: DimensionesApp.espacio16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          borderSide: BorderSide(color: colorBorde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          borderSide: BorderSide(color: colorBorde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          borderSide: const BorderSide(
            color: ColoresApp.turquesaRuta,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          borderSide: const BorderSide(color: ColoresApp.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          borderSide: const BorderSide(
            color: ColoresApp.error,
            width: 2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            0,
            DimensionesApp.altoBotonPrincipal,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionesApp.espacio20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            0,
            DimensionesApp.altoBotonPrincipal,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionesApp.espacio20,
          ),
          side: BorderSide(color: colorBorde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionesApp.radioMedio),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: esOscuro
            ? ColoresApp.superficieOscura
            : ColoresApp.superficieClara,
        indicatorColor: ColoresApp.turquesaRuta.withValues(alpha: 0.16),
      ),
      dividerTheme: DividerThemeData(
        color: colorBorde,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _crearTipografia(
    TextTheme base,
    Color principal,
    Color secundario,
  ) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        color: principal,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: principal,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: principal,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: principal,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: principal,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: secundario,
        height: 1.45,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  const TemaApp._();
}

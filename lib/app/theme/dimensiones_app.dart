/// Medidas base de la interfaz de Destino+.
///
/// La aplicación se diseña con prioridad para pantallas móviles. Centralizar
/// espacios y radios ayuda a mantener una interfaz consistente.
abstract final class DimensionesApp {
  // Espaciado.
  static const double espacio4 = 4;
  static const double espacio8 = 8;
  static const double espacio12 = 12;
  static const double espacio16 = 16;
  static const double espacio20 = 20;
  static const double espacio24 = 24;
  static const double espacio32 = 32;

  // Radios.
  static const double radioPequeno = 10;
  static const double radioMedio = 16;
  static const double radioGrande = 22;

  // Alturas táctiles.
  static const double altoControl = 52;
  static const double altoBotonPrincipal = 52;

  // Anchos de contenido para evitar interfaces excesivamente extendidas.
  static const double anchoContenidoMovil = 560;

  const DimensionesApp._();
}

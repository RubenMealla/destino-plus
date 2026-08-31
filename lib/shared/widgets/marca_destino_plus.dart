import 'package:flutter/material.dart';

import '../../app/theme/colores_app.dart';
import '../../app/theme/dimensiones_app.dart';

/// Identidad visual reutilizable de Destino+.
///
/// Se utiliza únicamente con recursos nativos de Flutter para mantener
/// la base del proyecto ligera y evitar dependencias gráficas prematuras.
class MarcaDestinoPlus extends StatelessWidget {
  const MarcaDestinoPlus({
    super.key,
    this.mostrarLema = true,
    this.alineacion = CrossAxisAlignment.start,
  });

  final bool mostrarLema;
  final CrossAxisAlignment alineacion;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: alineacion,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColoresApp.azulDestino,
                    ColoresApp.turquesaRuta,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  DimensionesApp.radioMedio,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.explore_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: DimensionesApp.espacio12),
            RichText(
              text: TextSpan(
                style: textTheme.headlineMedium,
                children: [
                  const TextSpan(text: 'Destino'),
                  TextSpan(
                    text: '+',
                    style: textTheme.headlineMedium?.copyWith(
                      color: ColoresApp.coralAcento,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (mostrarLema) ...[
          const SizedBox(height: DimensionesApp.espacio8),
          Text(
            'Organiza tu destino. Disfruta el camino.',
            style: textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

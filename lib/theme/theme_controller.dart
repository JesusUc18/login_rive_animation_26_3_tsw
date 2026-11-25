import 'package:flutter/material.dart';

/// Controlador global del modo de color (claro / oscuro).
/// MaterialApp lo escucha con ValueListenableBuilder.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.light,
);

/// Botón típico de sol / luna para cambiar entre modo día y noche.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Modo día' : 'Modo noche',
      onPressed: () {
        themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}

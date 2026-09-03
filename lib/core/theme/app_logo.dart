import 'package:flutter/material.dart';

/// OmniToolkit 3D Logo widget featuring the basket with calendar, radio, clock, and sunshine.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'omnitoolkit_logo_master.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.apps, size: size);
        },
      ),
    );
  }
}

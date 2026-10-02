import 'package:flutter/material.dart';

/// Product identity. Change the name here, in AndroidManifest android:label
/// and in assets/splash/*.svg together.
class Brand {
  static const name = 'Surge Budget';
  static const tagline = 'Your AI money agent';
  static const markAsset = 'assets/splash/surge_mark.svg';

  /// Splash background: matches the native launch screen so the hand-off is seamless.
  static const background = Color(0xFF04070F);
  static const backgroundGlow = Color(0xFF0E2A2A);
  static const mint = Color(0xFF6EE7B7);
  static const mintLight = Color(0xFFA7F3D0);
  static const emerald = Color(0xFF34D399);
}

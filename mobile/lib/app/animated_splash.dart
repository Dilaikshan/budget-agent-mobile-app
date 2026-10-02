import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'brand.dart';

/// Branded intro shown over the app on cold start. It continues the native
/// launch screen (same background and mark position), animates the mark,
/// a light "surge" sweep and the wordmark, then fades away. It never blocks
/// startup work: routing, database open and sync run underneath.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  bool _done = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Respect the system "remove animations" accessibility setting.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _intro.value = 1;
      Future<void>.delayed(const Duration(milliseconds: 350), _finish);
    } else {
      _intro.forward().whenComplete(_finish);
    }
  }

  Future<void> _finish() async {
    if (!mounted) return;
    // Hold the finished logo briefly before fading into the app.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _exit.forward();
    if (mounted) setState(() => _done = true);
  }

  @override
  void dispose() {
    _intro.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: FadeTransition(
            opacity: ReverseAnimation(
              CurvedAnimation(parent: _exit, curve: Curves.easeIn),
            ),
            child: AnimatedBuilder(
              animation: _intro,
              builder: (context, _) => Material(
                type: MaterialType.transparency,
                child: _SplashFrame(t: _intro.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One frame of the intro at progress [t] in 0..1.
class _SplashFrame extends StatelessWidget {
  const _SplashFrame({required this.t});

  final double t;

  double _seg(double from, double to, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final markIn = _seg(0.0, 0.38, Curves.easeOutBack);
    final markFade = _seg(0.0, 0.2);
    final sweep = _seg(0.28, 0.72, Curves.easeInOutCubic);
    final wordIn = _seg(0.45, 0.8);
    final tagIn = _seg(0.6, 0.95);
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final size = MediaQuery.sizeOf(context);
    final markSize = math.min(size.width * 0.5, 240.0);

    return Semantics(
      label: '${Brand.name}. ${Brand.tagline}',
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 0.95 + 0.05 * pulse,
            colors: const [Brand.backgroundGlow, Brand.background],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glow + mark with a diagonal light sweep that "surges" up the arrow.
              SizedBox(
                width: markSize * 1.6,
                height: markSize * 1.6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: markSize * (1.2 + 0.25 * markIn),
                      height: markSize * (1.2 + 0.25 * markIn),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Brand.emerald.withValues(
                              alpha: 0.30 * markFade * (0.7 + 0.3 * pulse),
                            ),
                            Brand.emerald.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: markFade,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          18 * (1 - markIn) - 6 * sweep * (1 - sweep),
                        ),
                        child: Transform.scale(
                          scale: 0.6 + 0.4 * markIn,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ShaderMask(
                                blendMode: BlendMode.srcATop,
                                shaderCallback: (rect) => LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.55),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                  stops: [
                                    (sweep * 1.4 - 0.4).clamp(0.0, 1.0),
                                    (sweep * 1.4 - 0.2).clamp(0.0, 1.0),
                                    (sweep * 1.4).clamp(0.0, 1.0),
                                  ],
                                ).createShader(rect),
                                child: SvgPicture.asset(
                                  Brand.markAsset,
                                  width: markSize,
                                  height: markSize,
                                ),
                              ),
                              _Mascot(t: t, markSize: markSize),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: wordIn,
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - wordIn)),
                  child: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Color(0xFFECFDF5), Brand.mint],
                    ).createShader(rect),
                    child: const Text(
                      Brand.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: tagIn * 0.8,
                child: Text(
                  Brand.tagline.toUpperCase(),
                  style: TextStyle(
                    color: Brand.mintLight,
                    fontSize: 13,
                    letterSpacing: 2 + 3 * tagIn,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static branded screen used while the session/database is still loading.
class BrandedLoading extends StatelessWidget {
  const BrandedLoading({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Brand.background,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Brand.markAsset,
            width: 120,
            height: 120,
            semanticsLabel: Brand.name,
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Brand.emerald,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The Surge Budget robot: drops onto the arrowhead, lands with a bounce,
/// waves and says "Hi!". Geometry is in the mark's 512-unit coordinate space
/// (see assets/splash/surge_mark_mascot.svg) so it scales with the mark.
class _Mascot extends StatelessWidget {
  const _Mascot({required this.t, required this.markSize});

  final double t;
  final double markSize;

  static const bodyAsset = 'assets/splash/robot_body.svg';
  static const armAsset = 'assets/splash/robot_arm.svg';

  double _seg(double from, double to, [Curve curve = Curves.linear]) =>
      curve.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final u = markSize / 512; // mark units -> logical pixels
    final drop = _seg(0.28, 0.44, Curves.bounceOut);
    final appear = _seg(0.28, 0.33);
    if (appear == 0) return const SizedBox.shrink();
    final landed = _seg(0.44, 1.0);
    final bob = landed > 0 ? math.sin(landed * math.pi * 4) * 1.5 : 0.0;
    // Three waves after landing, easing out at the end.
    final waveEnvelope = landed > 0
        ? math.sin(landed * math.pi).clamp(0.0, 1.0)
        : 0.0;
    final waveDeg = 34 + 20 * math.sin(landed * math.pi * 6) * waveEnvelope;
    final bubble = _seg(0.47, 0.60, Curves.elasticOut);

    final w = 97 * u; // robot body is 100x140 units scaled by 0.97
    final k = w / 100;
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 343.5 * u,
            top: 30 * u - (1 - drop) * markSize * 0.55 + bob,
            width: w,
            height: 140 * k,
            child: Opacity(
              opacity: appear,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: SvgPicture.asset(bodyAsset)),
                  Positioned(
                    left: 59 * k,
                    top: 31 * k,
                    width: 30 * k,
                    height: 50 * k,
                    child: Transform.rotate(
                      angle: waveDeg * math.pi / 180,
                      alignment: const Alignment(
                        0,
                        0.84,
                      ), // shoulder pivot (15,46)
                      child: SvgPicture.asset(armAsset),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (bubble > 0)
            Positioned(
              left: 246 * u,
              top: 26 * u,
              width: 110 * u,
              height: 50 * u,
              child: Transform.scale(
                scale: bubble,
                alignment: Alignment.centerRight,
                child: CustomPaint(
                  painter: _BubblePainter(),
                  child: Padding(
                    padding: EdgeInsets.only(right: 18 * u),
                    child: Center(
                      child: Text(
                        'Hi!',
                        style: TextStyle(
                          color: const Color(0xFF064E3B),
                          fontWeight: FontWeight.w800,
                          fontSize: 26 * u,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Rounded speech bubble with a tail pointing right toward the robot.
class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFECFDF5);
    final tail = size.width * 0.16;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width - tail, size.height),
      Radius.circular(size.height * 0.4),
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(size.width - tail - 2, size.height * 0.36)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width - tail - 2, size.height * 0.72)
      ..close();
    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

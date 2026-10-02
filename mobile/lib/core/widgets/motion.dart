import 'package:flutter/material.dart';

import '../domain/money.dart';
import 'common.dart';

/// Subtle motion helpers. All honour the system "remove animations" setting.
bool _reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Money that counts from its previous value to the new one. Interpolation is
/// on integer minor units (display only); screen readers get the final amount.
class CountUpMoney extends StatelessWidget {
  const CountUpMoney(
    this.minor, {
    super.key,
    required this.currency,
    required this.exponent,
    this.style,
  });

  final int minor;
  final String currency;
  final int exponent;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final finalText = formatMinor(
      minor,
      currency: currency,
      exponent: exponent,
    );
    if (_reduceMotion(context)) {
      return MoneyText(
        minor,
        currency: currency,
        exponent: exponent,
        style: style,
      );
    }
    return Semantics(
      label: finalText,
      excludeSemantics: true,
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: minor),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => MoneyText(
          value,
          currency: currency,
          exponent: exponent,
          style: style,
        ),
      ),
    );
  }
}

/// Fades and slides a child in once, delayed by its [index] in a list.
class StaggerIn extends StatefulWidget {
  const StaggerIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_reduceMotion(context)) {
      _c.value = 1;
    } else {
      Future<void>.delayed(
        Duration(milliseconds: 60 * widget.index.clamp(0, 8)),
        () {
          if (mounted) _c.forward();
        },
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(_a),
      child: widget.child,
    ),
  );
}

/// Wraps each widget of a list in [StaggerIn].
List<Widget> staggered(List<Widget> children) => [
  for (var i = 0; i < children.length; i++)
    StaggerIn(key: ValueKey('stagger-$i'), index: i, child: children[i]),
];

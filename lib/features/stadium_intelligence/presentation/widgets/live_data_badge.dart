import 'package:flutter/material.dart';

/// Reusable blinking "LIVE DATA" or "LIVE" badge widget.
class LiveDataBadge extends StatefulWidget {
  final String label;
  final double fontSize;
  final bool compact;

  const LiveDataBadge({
    super.key,
    this.label = 'LIVE DATA',
    this.fontSize = 10,
    this.compact = false,
  });

  @override
  State<LiveDataBadge> createState() => _LiveDataBadgeState();
}

class _LiveDataBadgeState extends State<LiveDataBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 6 : 10,
            vertical: widget.compact ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: _animation.value,
                child: Container(
                  width: widget.compact ? 6 : 8,
                  height: widget.compact ? 6 : 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(_animation.value * 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: widget.compact ? 4 : 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A helper since AnimatedBuilder is the old name
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

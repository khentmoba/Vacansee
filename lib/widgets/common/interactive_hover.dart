import 'package:flutter/material.dart';

class InteractiveHover extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final Curve curve;

  const InteractiveHover({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.02,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<InteractiveHover> createState() => _InteractiveHoverState();
}

class _InteractiveHoverState extends State<InteractiveHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasCallback = widget.onTap != null;

    return MouseRegion(
      onEnter: (_) {
        if (hasCallback) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (hasCallback) setState(() => _isHovered = false);
      },
      cursor: hasCallback ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isHovered ? widget.scale : 1.0,
              _isHovered ? widget.scale : 1.0,
              1.0,
              1.0,
            ),
          child: widget.child,
        ),
      ),
    );
  }
}

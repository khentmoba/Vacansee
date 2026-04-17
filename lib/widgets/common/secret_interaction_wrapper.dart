import 'package:flutter/material.dart';

/// A wrapper that detects a secret interaction sequence (e.g., 5 rapid clicks)
/// to trigger a hidden action.
class SecretInteractionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTrigger;
  final int requiredClicks;
  final Duration timeout;

  const SecretInteractionWrapper({
    super.key,
    required this.child,
    required this.onTrigger,
    this.requiredClicks = 5,
    this.timeout = const Duration(milliseconds: 500),
  });

  @override
  State<SecretInteractionWrapper> createState() => _SecretInteractionWrapperState();
}

class _SecretInteractionWrapperState extends State<SecretInteractionWrapper> with SingleTickerProviderStateMixin {
  int _clickCount = 0;
  DateTime? _lastClickTime;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();
    
    // Reset if timeout exceeded
    if (_lastClickTime != null && now.difference(_lastClickTime!) > widget.timeout) {
      _clickCount = 0;
    }

    _clickCount++;
    _lastClickTime = now;

    // Trigger visual feedback (subtle glow)
    _controller.forward(from: 0.0).then((_) => _controller.reverse());

    if (_clickCount >= widget.requiredClicks) {
      _clickCount = 0;
      widget.onTrigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          // Subtle feedback layer
          FadeTransition(
            opacity: _animation,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5287B2).withValues(alpha: 0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

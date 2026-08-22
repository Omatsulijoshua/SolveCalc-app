import 'package:flutter/material.dart';

enum ButtonType {
  number,
  operator,
  function,
  equals,
  clear,
}

class CalculatorButton extends StatefulWidget {
  final String text;
  final Widget? icon;
  final ButtonType type;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final int flex;

  const CalculatorButton({
    super.key,
    required this.text,
    this.icon,
    this.type = ButtonType.number,
    required this.onTap,
    this.onLongPress,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 22,
    this.flex = 1,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(18),
            elevation: widget.type == ButtonType.equals ? 3 : 0,
            shadowColor: widget.backgroundColor.withAlpha(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              splashColor: Colors.white.withAlpha(40),
              highlightColor: Colors.white.withAlpha(20),
              child: Center(
                child: widget.icon ??
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: widget.type == ButtonType.number
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: widget.textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

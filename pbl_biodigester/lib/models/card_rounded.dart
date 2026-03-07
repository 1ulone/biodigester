import 'package:flutter/material.dart';

class CardRounded extends StatelessWidget {
    final Widget child;
    final double height;
    final double width;
    final Padding padding;

    const CardRounded({super.key, required this.child, required this.height, required this.width, this.padding = const Padding(padding: EdgeInsets.all(16.0))});

    @override
    Widget build(BuildContext context) {
        return Container(
            height: height,
            width: width,
            padding: padding.padding,
            decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    spreadRadius: 0.2,
                    blurRadius: 1,
                    offset: const Offset(0, -4),
                    ),
                ],
                ),
            child: child,
        );
    }
}

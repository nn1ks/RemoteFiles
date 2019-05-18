import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final double size;
  final EdgeInsets padding;
  final Color splashColor;
  final GestureTapCallback onPressed;

  CustomIconButton({
    @required this.icon,
    this.size = 44.0,
    this.padding = const EdgeInsets.all(8.0),
    this.splashColor,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: InkWell(
        borderRadius: BorderRadius.circular(size),
        onTap: onPressed,
        splashColor: splashColor,
        child: Container(
          padding: padding,
          width: size,
          height: size,
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FloatingActionRow extends StatelessWidget {
  final List<Widget> children;
  final Color color;
  final double elevation;
  final double height;
  final String heroTag;

  /// The first and the last item must be a `FloatingActionRowButton`
  FloatingActionRow({
    @required this.children,
    this.elevation = 6.0,
    this.color,
    this.height = 56.0,
    this.heroTag,
  });

  List<Widget> _addPadding(List<Widget> widgets) {
    List<FloatingActionRowButton> buttons = [
      widgets[0],
      widgets[widgets.length - 1]
    ];
    widgets[0] = buttons[0].copyWith(padding: EdgeInsets.only(left: 4.0));
    widgets[widgets.length - 1] =
        buttons[1].copyWith(padding: EdgeInsets.only(right: 4.0));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    Widget result;

    result = PhysicalModel(
      color: Colors.transparent,
      elevation: elevation,
      borderRadius: BorderRadius.circular(height / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).accentColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: _addPadding(children),
          ),
        ),
      ),
    );

    if (heroTag != null) {
      result = Hero(
        tag: heroTag,
        child: result,
      );
    }

    return result;
  }
}

class FloatingActionRowButton extends StatelessWidget {
  final Icon icon;
  final Color color;
  final double size;
  final EdgeInsets padding;
  final GestureTapCallback onPressed;

  FloatingActionRowButton({
    @required this.icon,
    this.color,
    this.size = 56.0,
    this.padding,
    @required this.onPressed,
  }) : super();

  copyWith({
    Icon icon,
    Color color,
    double size,
    EdgeInsets padding,
    GestureTapCallback onPressed,
  }) {
    return FloatingActionRowButton(
      icon: icon ?? this.icon,
      color: color ?? this.color,
      size: size ?? this.size,
      padding: padding ?? this.padding,
      onPressed: onPressed ?? this.onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result;

    result = SizedBox(
      width: size,
      height: size,
      child: RawMaterialButton(
        padding: padding ?? EdgeInsets.all(0),
        onPressed: onPressed,
        child: IconTheme.merge(
          data: IconThemeData(
            color: color ??
                Theme.of(context).floatingActionButtonTheme.foregroundColor ??
                Theme.of(context).accentIconTheme.color ??
                Theme.of(context).colorScheme.onSecondary,
          ),
          child: icon,
        ),
      ),
    );

    return result;
  }
}

class FloatingActionRowDivider extends StatelessWidget {
  final Color color;
  final EdgeInsets padding;

  FloatingActionRowDivider({this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    Color color = this.color ??
        Theme.of(context).floatingActionButtonTheme.foregroundColor ??
        Theme.of(context).accentIconTheme.color ??
        Theme.of(context).colorScheme.onSecondary ??
        Colors.white;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: 1.0,
        height: constraints.maxHeight,
        margin: EdgeInsets.symmetric(vertical: 10.0),
        color: color.withAlpha(60),
      );
    });
  }
}

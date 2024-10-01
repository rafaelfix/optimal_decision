import 'package:flutter/material.dart';

/// Places widgets in an expandable grid
/// Grows Vertically and then Horizontally
/// meaning that sub lists are rows and the main list is a column
///
// class Menu extends StatelessWidget {
//   final List<List<Widget>> children;

/// A button which navigates to a new page.
///
/// [title] is used to set the button text.
/// [page] is the page to navigate to on click.
/// [icon] is the icon to display on the button.
/// [locked] is used to determine if the button should be disabled.
class NavigateButton extends StatelessWidget {
  const NavigateButton({
    Key? key,
    required this.title,
    required this.page,
    this.completed = false,
    this.icon,
    this.image,
    this.color,
    this.locked = false,
    this.routeName = "",
  })  : assert(icon != null || image != null),
        super(key: key);

  final String title;
  final Widget page;
  final Widget? icon;
  final Image? image;
  final Color? color;
  final bool locked;
  final bool completed;
  final String routeName;
  static const disabledColor = Colors.black38; // Color to used when locked

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color ?? Colors.amber,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: MaterialButton(
            padding: const EdgeInsets.all(15),
            textColor: Colors.black,
            disabledColor:
                completed ? disabledColor.withAlpha(0) : disabledColor,
            shape: const CircleBorder(),
            child: LayoutBuilder(builder: (context, constraint) {
              return SizedBox(
                child: icon,
                width: constraint.maxWidth,
                height: constraint.maxHeight,
              );
            }),
            onPressed: locked
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: RouteSettings(name: routeName),
                          builder: (context) => page),
                    );
                  },
          ),
        ),
        if (completed)
          const Positioned.fill(
            child: FractionalTranslation(
              translation: Offset(0.4, -0.3),
              child: Icon(
                Icons.check_sharp,
                color: Colors.black,
                size: 50,
              ),
            ),
          ),
        if (locked && !completed)
          Container(
            alignment: const Alignment(1.4, -1.4),
            child: const Icon(
              Icons.lock,
              color: Colors.black45,
              size: 40,
            ),
          ),
        completed
            ? const Positioned.fill(
                child: FractionalTranslation(
                  translation: Offset(0.4, -0.32),
                  child: Icon(
                    Icons.check_sharp,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}

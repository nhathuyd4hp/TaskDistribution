import 'package:fluent_ui/fluent_ui.dart';

class WindownButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget child;
  const WindownButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xff0067c0)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

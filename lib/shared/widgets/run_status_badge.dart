import 'package:fluent_ui/fluent_ui.dart';
import 'package:task_distribution/model/run.dart';

class RunStatusBadge extends StatelessWidget {
  final Run run;

  const RunStatusBadge({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Widget prefix;
    String text = run.status;

    switch (run.status.toLowerCase()) {
      case 'waiting':
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF9A825);
        prefix = Icon(FluentIcons.hour_glass, size: 15, color: textColor);
        break;
      case 'success':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        prefix = Icon(FluentIcons.completed12, size: 15, color: textColor);
        break;
      case 'failure':
      case 'error':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        prefix = Icon(FluentIcons.error, size: 15, color: textColor);
        break;
      case 'pending':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        prefix = SizedBox(
          height: 15,
          width: 15,
          child: ProgressRing(strokeWidth: 2.5, activeColor: textColor),
        );
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        prefix = Icon(FluentIcons.unknown, size: 15, color: textColor);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          prefix,
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

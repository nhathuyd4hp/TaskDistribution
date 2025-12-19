import 'package:fluent_ui/fluent_ui.dart';
import 'package:task_distribution/model/run.dart';

class StatusBadge extends StatelessWidget {
  final Run run;

  const StatusBadge({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text = run.status;

    switch (run.status.toLowerCase()) {
      case 'waiting':
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF9A825);
        icon = FluentIcons.hour_glass;
        break;
      case 'success':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = FluentIcons.check_mark;
        break;
      case 'failure':
      case 'error':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = FluentIcons.error;
        break;
      case 'pending':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        icon = FluentIcons.clock;
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        icon = FluentIcons.unknown;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

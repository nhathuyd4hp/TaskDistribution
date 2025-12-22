import 'package:fluent_ui/fluent_ui.dart';
import 'package:task_distribution/provider/socket.dart';

class ServerStatusBadge extends StatelessWidget {
  final ConnectionStatus status;

  const ServerStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case ConnectionStatus.connecting:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF9A825);
        break;
      case ConnectionStatus.connected:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case ConnectionStatus.disconnected:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
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
            WindowsIcon(FluentIcons.location_dot, size: 12, color: textColor),
            const SizedBox(width: 6),
            Text(
              status.name.toUpperCase(),
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

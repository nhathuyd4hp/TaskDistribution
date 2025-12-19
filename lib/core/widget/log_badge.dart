import 'package:fluent_ui/fluent_ui.dart';

class LogText extends StatelessWidget {
  final String level;

  const LogText({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color textColor;

    // Viết hoa chữ cái đầu
    String text = level.isEmpty
        ? 'Unknown'
        : '${level[0].toUpperCase()}${level.substring(1).toLowerCase()}';

    switch (level.toLowerCase()) {
      case 'info':
      case 'information':
        textColor = const Color(0xFF0277BD); // Xanh dương đậm
        break;

      case 'warn':
      case 'warning':
        textColor = const Color(0xFFF57F17); // Cam đậm
        break;

      case 'error':
      case 'critical':
      case 'fatal':
        textColor = const Color(0xFFC62828); // Đỏ đậm
        break;

      case 'debug':
      case 'trace':
        textColor = const Color(0xFF7B1FA2); // Tím đậm
        break;

      default:
        textColor = const Color(0xFF616161); // Xám đậm
    }

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600, // In đậm nhẹ để dễ đọc màu
      ),
    );
  }
}

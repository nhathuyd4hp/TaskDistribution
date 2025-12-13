import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import 'package:task_distribution/provider/page.dart';

class Header extends StatelessWidget {
  final EdgeInsets padding;
  const Header({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final pageState = context.watch<PageProvider>();
    final theme = FluentTheme.of(context);

    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
            width: 1,
          ),
        ),
      ),
      child: Row(
        spacing: 50,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Robot Automation", style: theme.typography.title),
          Row(
            spacing: 25,
            children: [
              _buildNavItem(
                context,
                label: "Robot",
                icon: FluentIcons.robot,
                onPressed: () => pageState.setPage(AppPage.robot),
              ),
              _buildNavItem(
                context,
                label: "Runs",
                icon: FluentIcons.history,
                onPressed: () => pageState.setPage(AppPage.runs),
              ),
              _buildNavItem(
                context,
                label: "Schedule",
                icon: FluentIcons.calendar,
                onPressed: () => pageState.setPage(AppPage.schedule),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

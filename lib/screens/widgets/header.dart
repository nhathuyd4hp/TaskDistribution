import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import 'package:task_distribution/providers/page.dart';

class Header extends StatelessWidget {
  final EdgeInsets padding;
  const Header({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final pageState = context.watch<PageProvider>();
    //
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
        children: [
          Text("Robot Automation", style: theme.typography.title),
          Row(
            spacing: 25,
            children: [
              _buildNavItem(
                context,
                label: "Robot",
                icon: FluentIcons.robot,
                isActive: pageState.currentPage == AppPage.robot,
                onPressed: () => pageState.setPage(AppPage.robot),
              ),
              _buildNavItem(
                context,
                label: "Runs",
                icon: FluentIcons.history,
                isActive: pageState.currentPage == AppPage.runs,
                onPressed: () => pageState.setPage(AppPage.runs),
              ),
              _buildNavItem(
                context,
                label: "Schedule",
                icon: FluentIcons.calendar,
                isActive: pageState.currentPage == AppPage.schedule,
                onPressed: () => pageState.setPage(AppPage.schedule),
              ),
              _buildNavItem(
                context,
                label: "Execution Log",
                icon: FluentIcons.documentation,
                isActive: pageState.currentPage == AppPage.log,
                onPressed: () => pageState.setPage(AppPage.log),
              ),
            ],
          ),
          Spacer(),
          // FilledButton(
          //   onPressed: () {},
          //   child: Row(
          //     spacing: 10,
          //     children: [
          //       Icon(FluentIcons.signin, size: 16),
          //       Text(
          //         "Log In",
          //         style: const TextStyle(fontWeight: FontWeight.w600),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    if (!isActive) {
      return Button(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isHovered) {
              return FluentTheme.of(context).resources.subtleFillColorSecondary;
            }
            return Colors.transparent;
          }),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(icon, size: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, size: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

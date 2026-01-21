import "package:fluent_ui/fluent_ui.dart";

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState({
    super.key,
    this.message = "No results match your filters",
    this.icon = FluentIcons.search,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 25,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.grey),
          Text(message, style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

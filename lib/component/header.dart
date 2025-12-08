import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "../provider/page.dart";

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final pageState = context.read<PageProvider>();
    return Column(
      children: [
        Container(
          height: 75,
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Danh sách Robot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton(
                    onPressed: () => pageState.setPage(AppPage.robot),
                    child: const Text('Robot'),
                  ),
                  FilledButton(
                    onPressed: () => pageState.setPage(AppPage.runs),
                    child: const Text('Lịch sử chạy'),
                  ),
                  FilledButton(
                    onPressed: () => pageState.setPage(AppPage.schedule),
                    child: const Text('Lịch trình chạy'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}

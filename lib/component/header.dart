import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "../state/page.dart";

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final pageState = context.read<PageState>();
    return Container(
      height: 75,
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Robot Managament"),
          Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Button(
                child: const Text('Robot'),
                onPressed: () => pageState.setPage(AppPage.robot),
              ),
              Button(
                child: const Text('History'),
                onPressed: () => pageState.setPage(AppPage.runs),
              ),
              Button(
                child: const Text('Schedule'),
                onPressed: () => pageState.setPage(AppPage.schedule),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/win_button.dart";
import 'package:task_distribution/provider/page.dart';

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
                "QUẢN LÍ ROBOT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Row(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  WindownButton(
                    child: Text('Robot'),
                    onPressed: () => pageState.setPage(AppPage.robot),
                  ),
                  WindownButton(
                    child: Text('Lịch sử chạy'),
                    onPressed: () => pageState.setPage(AppPage.runs),
                  ),
                  WindownButton(
                    child: Text('Lịch trình chạy'),
                    onPressed: () => pageState.setPage(AppPage.schedule),
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

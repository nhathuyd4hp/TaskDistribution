import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/service/robot.dart';
import 'package:task_distribution/provider/page.dart';
import 'package:task_distribution/provider/robot.dart';
import 'package:task_distribution/provider/socket.dart';
import 'package:window_manager/window_manager.dart';
import "screen/home.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(750, 525),
    size: Size(1000, 700),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // Run
  runApp(const TaskDistribution());
}

class TaskDistribution extends StatelessWidget {
  const TaskDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageProvider()),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => ServerProvider("ws://127.0.0.1:8000/ws"),
        ),
        ChangeNotifierProxyProvider<ServerProvider, RobotProvider>(
          create: (_) => RobotProvider(RobotClient('http://127.0.0.1:8000')),
          update: (_, serverProvider, robotProvider) {
            robotProvider!.bindServer(serverProvider);
            return robotProvider;
          },
        ),
      ],
      child: FluentApp(
        title: "Task Distribution",
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}

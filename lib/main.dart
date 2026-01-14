import 'package:fluent_ui/fluent_ui.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/provider/robot/robot_filter.dart';
import 'package:task_distribution/provider/run/run.dart';
import 'package:task_distribution/provider/run/run_filter.dart';
import 'package:task_distribution/provider/schedule/schedule.dart';
import 'package:task_distribution/service/robot.dart';
import 'package:task_distribution/provider/page.dart';
import 'package:task_distribution/provider/robot/robot.dart';
import 'package:task_distribution/provider/socket.dart';
import 'package:task_distribution/service/run.dart';
import 'package:task_distribution/service/schedule.dart';
import 'package:window_manager/window_manager.dart';
import "screen/home.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(1400, 800),
    size: Size(1400, 800),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  //
  await localNotifier.setup(
    appName: 'Robot Automation',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
  // Run
  runApp(const TaskDistribution());
}

class TaskDistribution extends StatelessWidget {
  // -- Enviroment
  static const String domain = String.fromEnvironment(
    'domain',
    defaultValue: "127.0.0.1:8000",
  );
  static const bool https = bool.fromEnvironment('https', defaultValue: false);
  // -- Schema --
  static const String httpScheme = https ? 'https' : 'http';
  static const String wsScheme = https ? 'wss' : 'ws';
  // -- Domain
  static const String backendUrl = '$httpScheme://$domain';
  static const String wsUrl = '$wsScheme://$domain/ws';

  const TaskDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Navigation State
        ChangeNotifierProvider(create: (_) => PageProvider()),
        // Server State
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => ServerProvider(wsUrl),
        ),
        // Data State
        ChangeNotifierProxyProvider<ServerProvider, RobotProvider>(
          create: (BuildContext context) => RobotProvider(
            repository: RobotClient(backendUrl),
            server: context.read<ServerProvider>(),
          ),
          update: (_, serverProvider, robotProvider) {
            robotProvider!.bindServer();
            return robotProvider;
          },
        ),
        ChangeNotifierProxyProvider<ServerProvider, RunProvider>(
          create: (BuildContext context) => RunProvider(
            repository: RunClient(backendUrl),
            server: context.read<ServerProvider>(),
          ),
          update: (_, serverProvider, runProvider) {
            runProvider!.bindServer();
            return runProvider;
          },
        ),
        ChangeNotifierProxyProvider<ServerProvider, ScheduleProvider>(
          create: (BuildContext context) => ScheduleProvider(
            repository: ScheduleClient(backendUrl),
            server: context.read<ServerProvider>(),
          ),
          update: (_, serverProvider, scheduleProvider) {
            scheduleProvider!.bindServer();
            return scheduleProvider;
          },
        ),
        // Filter State
        ChangeNotifierProvider(create: (_) => RobotFilterProvider()),
        ChangeNotifierProvider(create: (_) => RunFilterProvider()),
      ],
      child: FluentApp(
        title: "Task Distribution",
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: FluentThemeData(
          accentColor: Colors.teal,
          brightness: Brightness.light,
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),

        // --- DARK THEME ---
        darkTheme: FluentThemeData(
          accentColor: Colors.teal,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xff111823),
          cardColor: const Color(0xff19222c),
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
        ),
        home: Home(),
      ),
    );
  }
}

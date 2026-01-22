import 'package:fluent_ui/fluent_ui.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:provider/provider.dart';
import 'package:task_distribution/providers/robot/robot_filter.dart';
import 'package:task_distribution/providers/run/run.dart';
import 'package:task_distribution/providers/run/run_filter.dart';
import 'package:task_distribution/providers/schedule/schedule.dart';
import 'package:task_distribution/screens/home/home.dart';
import 'package:task_distribution/data/services/robot.dart';
import 'package:task_distribution/providers/page.dart';
import 'package:task_distribution/providers/robot/robot.dart';
import 'package:task_distribution/providers/socket.dart';
import 'package:task_distribution/data/services/run.dart';
import 'package:task_distribution/data/services/schedule.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(1050, 600),
    size: Size(1050, 600),
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
  runApp(const RobotAutomation());
}

class RobotAutomation extends StatelessWidget {
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

  const RobotAutomation({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageProvider()),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => ServerProvider(wsUrl),
        ),
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
        ChangeNotifierProvider(create: (_) => RobotFilterProvider()),
        ChangeNotifierProvider(create: (_) => RunFilterProvider()),
      ],
      child: FluentApp(
        title: "Robot Automation",
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        // --- LIGHT THEME ---
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

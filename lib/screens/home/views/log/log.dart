import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:task_distribution/shared/widgets/run_status_badge.dart';
import 'package:task_distribution/main.dart';
import 'package:task_distribution/data/model/log.dart';
import 'package:task_distribution/data/model/run.dart';
import 'package:task_distribution/data/model/run_error.dart';
import 'package:task_distribution/providers/run/run.dart';
import 'package:task_distribution/providers/run/run_filter.dart'; // Import quan trọng
import "package:task_distribution/providers/socket.dart";
import 'package:task_distribution/screens/home/views/log/widgets/log_badge.dart';

class ExecutionLogPage extends StatefulWidget {
  const ExecutionLogPage({super.key});

  @override
  State<ExecutionLogPage> createState() => _ExecutionLogPageState();
}

class _ExecutionLogPageState extends State<ExecutionLogPage> {
  List<LogEntry> logs = [];
  StreamSubscription? _logSubscription;
  final ScrollController _scrollController = ScrollController();

  String? _currentLoadedId;

  @override
  void initState() {
    super.initState();
    final providerId = context.read<RunFilterProvider>().selectedId;
    if (providerId != null) {
      _currentLoadedId = providerId;
      _connectLogStream(providerId);
    }
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _connectLogStream(String runId) async {
    await _logSubscription?.cancel();

    if (!mounted) return;
    setState(() {
      logs.clear();
      _currentLoadedId = runId;
    });

    try {
      final uri = Uri.parse('${RobotAutomation.backendUrl}/api/logs/$runId');
      final request = http.Request('GET', uri);
      final response = await request.send();
      if (response.statusCode == 200) {
        _logSubscription = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((String line) {
              if (line.trim().isEmpty) return;
              if (mounted) {
                setState(() {
                  logs.add(LogEntry.fromRawLine(line));
                });
                _scrollToBottom();
              }
            });
      }
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<RError?> _getRError(BuildContext context, String runId) async {
    return await context.read<RunProvider>().getError(runId);
  }

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final filterProvider = context.watch<RunFilterProvider>(); // Watch filter
    final server = context.watch<ServerProvider>();
    final theme = FluentTheme.of(context);

    final displayId = filterProvider.selectedId;

    Run? currentRun;
    if (displayId != null) {
      try {
        currentRun = runProvider.runs.firstWhere((r) => r.id == displayId);
      } catch (_) {}
    }

    if (displayId != null && displayId != _currentLoadedId) {
      Future.microtask(() => _connectLogStream(displayId));
    }

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Execution Log'),
        commandBar: AutoSuggestBox<String>(
          placeholder: 'Search...',
          controller: displayId != null
              ? TextEditingController(text: displayId)
              : null,
          leadingIcon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(FluentIcons.search),
          ),
          items: runProvider.runs.map((run) {
            return AutoSuggestBoxItem<String>(
              value: run.id,
              label: run.id,
              child: Text(
                run.id,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onSelected: () {
                context.read<RunFilterProvider>().setSelectedId(run.id);
              },
            );
          }).toList(),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          spacing: 16,
          children: [
            if (displayId != null && currentRun != null)
              _buildRunInfoPanel(theme, currentRun),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.resources.dividerStrokeColorDefault,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: server.status != ConnectionStatus.connected
                      ? [
                          Expanded(
                            child: Center(
                              child:
                                  server.status == ConnectionStatus.connecting
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Lottie.asset(
                                          'assets/lottie/Loading.json',
                                          width: 250,
                                          height: 250,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Connecting to server...",
                                          style: theme.typography.bodyStrong,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FluentIcons.plug_disconnected,
                                          size: 48,
                                          color: theme
                                              .resources
                                              .textFillColorSecondary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Disconnected",
                                          style: theme.typography.title,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          server.errorMessage ??
                                              "Lost connection to server",
                                          style: theme.typography.bodyStrong,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ]
                      : [
                          _buildLogTableHeader(theme, currentRun),
                          const Divider(),
                          Expanded(
                            child: logs.isEmpty
                                ? Center(
                                    child: Text(
                                      displayId == null
                                          ? "Select a run to view logs"
                                          : "Waiting for logs...",
                                    ),
                                  )
                                : ListView.separated(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: logs.length,
                                    separatorBuilder: (ctx, i) => Divider(
                                      style: DividerThemeData(
                                        thickness: 0.5,
                                        decoration: BoxDecoration(
                                          color: theme
                                              .resources
                                              .dividerStrokeColorDefault,
                                        ),
                                      ),
                                    ),
                                    itemBuilder: (context, index) {
                                      return _buildLogTableRow(
                                        logs[index],
                                        theme,
                                      );
                                    },
                                  ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS (Giữ nguyên layout bạn đã duyệt) ---

  Widget _buildRunInfoPanel(FluentThemeData theme, Run run) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Run ID: ${run.id}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RunStatusBadge(run: run),
            ],
          ),
          const Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 35,
            children: [
              _buildInfoItem("Robot", run.robot, FluentIcons.robot),
              _buildInfoItem(
                "Run At",
                run.runAt != null ? run.runAt.toString().split('.')[0] : " ",
                FluentIcons.clock,
              ),
              _buildInfoItem(
                "Parameters",
                run.parameters != null
                    ? (jsonDecode(run.parameters!) as Map).entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join('\n')
                    : "",
                FluentIcons.variable,
              ),
              if (run.status == "SUCCESS" &&
                  run.result != null &&
                  run.result != "")
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(
                        FluentIcons.file_system,
                        size: 16,
                        color: Colors.grey[100],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Result",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[100],
                            ),
                          ),
                          Text(
                            p.basename(run.result!),
                            maxLines: 1,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: Colors.grey[100]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[100]),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogTableHeader(FluentThemeData theme, Run? run) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: theme.resources.textFillColorSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text("TIMESTAMP", style: style)),
          SizedBox(width: 100, child: Text("LEVEL", style: style)),
          SizedBox(width: 100, child: Text("MESSAGE", style: style)),
          Spacer(),
          SizedBox(
            width: 105,
            child: (run == null)
                ? null
                : run.status == "PENDING" || run.status == "WAITING"
                ? StopAction(context: context, run: run)
                : run.status != "FAILURE"
                ? DownloadAction(context: context, run: run)
                : FilledButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => FutureBuilder<RError?>(
                          future: _getRError(context, run.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ContentDialog(
                                title: Row(
                                  spacing: 5,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      'assets/lottie/Loading.json',
                                      width: 32,
                                      height: 32,
                                    ),
                                    Text("Loading..."),
                                  ],
                                ),
                                content: SizedBox(
                                  height: 60,
                                  child: Center(child: ProgressBar()),
                                ),
                              );
                            }
                            RError error;
                            if (snapshot.hasError || snapshot.data == null) {
                              error = RError(
                                id: run.id,
                                runId: run.id,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                errorType: "Error",
                                message: run.result ?? "",
                                traceback: run.result ?? "",
                              );
                            } else {
                              error = snapshot.data!;
                            }
                            return ContentDialog(
                              constraints: const BoxConstraints(maxWidth: 850),
                              title: Text(
                                error.errorType,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expander(
                                    initiallyExpanded: true,
                                    header: Row(
                                      children: [
                                        Icon(
                                          FluentIcons.info,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          "Error Message",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.05,
                                        ), // Nền đỏ rất nhạt
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.red.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                      ),
                                      child: SelectableText(
                                        error.message,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Traceback:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: TextBox(
                                      readOnly: true,
                                      maxLines: null,
                                      expands: true,
                                      controller: TextEditingController(
                                        text: error.traceback,
                                      ),
                                      style: const TextStyle(
                                        fontFamily: 'Consolas',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              actions: [
                                Button(
                                  child: const Text('Close'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color.fromARGB(255, 214, 78, 78),
                      ),
                    ),
                    child: Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.error, size: 12),
                        Text("Error"),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTableRow(LogEntry log, FluentThemeData theme) {
    final monoStyle = TextStyle(
      fontSize: 13,
      fontFamily: 'Consolas',
      color: theme.typography.body!.color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '${log.timestamp.year}-'
              '${log.timestamp.month.toString().padLeft(2, '0')}-'
              '${log.timestamp.day.toString().padLeft(2, '0')} '
              '${log.timestamp.hour.toString().padLeft(2, '0')}:'
              '${log.timestamp.minute.toString().padLeft(2, '0')}:'
              '${log.timestamp.second.toString().padLeft(2, '0')}',
              style: monoStyle.copyWith(
                color: theme.resources.textFillColorPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: LogBadge(level: log.level),
            ),
          ),
          Expanded(child: SelectableText(log.message, style: monoStyle)),
        ],
      ),
    );
  }
}

class DownloadAction extends StatelessWidget {
  final Run run;
  const DownloadAction({super.key, required this.context, required this.run});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final isDownloading = context.select<RunProvider, bool>(
      (provider) => provider.downloading[run.id] ?? false,
    );
    if (isDownloading) {
      return const ProgressBar();
    }
    return FilledButton(
      onPressed: () {
        context.read<RunProvider>().download(run);
      },
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(FluentIcons.download, size: 12), Text("Download")],
      ),
    );
  }
}

class StopAction extends StatelessWidget {
  final Run run;
  const StopAction({super.key, required this.context, required this.run});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        context.read<RunProvider>().stop(run);
      },
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(FluentIcons.pause, size: 12), Text("Stop")],
      ),
    );
  }
}

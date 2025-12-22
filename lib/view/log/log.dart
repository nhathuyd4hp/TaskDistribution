import 'dart:async';
import 'dart:convert';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:task_distribution/core/widget/log_badge.dart';
import 'package:task_distribution/core/widget/run_status_badge.dart';
import 'package:task_distribution/main.dart';
import 'package:task_distribution/model/log.dart';
import 'package:task_distribution/model/run.dart';
import 'package:task_distribution/provider/run/run.dart';

class ExecutionLogPage extends StatefulWidget {
  const ExecutionLogPage({super.key});

  @override
  State<ExecutionLogPage> createState() => _ExecutionLogPageState();
}

class _ExecutionLogPageState extends State<ExecutionLogPage> {
  List<LogEntry> logs = [];
  String? selectedRunId;
  StreamSubscription? _logSubscription;

  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }

  void _connectLogStream(String runId) async {
    await _logSubscription?.cancel();

    setState(() {
      logs.clear();
    });

    final uri = Uri.parse('${TaskDistribution.backendUrl}/api/logs/$runId');
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
                final logEntry = LogEntry.fromRawLine(line);
                setState(() {
                  logs.add(logEntry);
                });
              });
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final theme = FluentTheme.of(context);
    Run? currentRun;
    if (selectedRunId != null) {
      currentRun = runProvider.runs.firstWhere((r) => r.id == selectedRunId);
    }
    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Execution Log'),
        commandBar: AutoSuggestBox<String>(
          placeholder: 'Search...',
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
                setState(() {
                  selectedRunId = run.id;
                });
                _connectLogStream(run.id);
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
            if (selectedRunId != null && currentRun != null)
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
                  children: [
                    _buildLogTableHeader(theme, currentRun),
                    const Divider(),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: logs.length,
                        separatorBuilder: (ctx, i) => Divider(
                          style: DividerThemeData(
                            thickness: 0.5,
                            decoration: BoxDecoration(
                              color: theme.resources.dividerStrokeColorDefault,
                            ),
                          ),
                        ),
                        itemBuilder: (context, index) {
                          return _buildLogTableRow(logs[index], theme);
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
                "Run Details: ${run.id}",
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
            spacing: 50,
            children: [
              _buildInfoItem("Robot Name", run.robot, FluentIcons.robot),
              _buildInfoItem(
                "Started At",
                run.createdAt.toString(),
                FluentIcons.clock,
              ),
              Expanded(
                child: _buildInfoItem(
                  "Parameters",
                  run.parameters ?? "",
                  FluentIcons.variable,
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
      children: [
        Icon(icon, size: 16, color: Colors.grey[100]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[100]),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          SizedBox(width: 200, child: Text("TIMESTAMP", style: style)),
          SizedBox(width: 100, child: Text("LEVEL", style: style)),
          Expanded(child: Text("MESSAGE", style: style)),
          SizedBox(
            width: 100,
            child: FilledButton(
              child: const Text("Result"),
              onPressed: () {
                if (run != null) {
                  final provider = context.read<RunProvider>();
                  provider.download(run);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTableRow(LogEntry log, FluentThemeData theme) {
    final monoStyle = TextStyle(
      fontSize: 13,
      color: theme.typography.body!.color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Timestamp
          SizedBox(
            width: 200,
            child: Text(
              log.timestamp.toIso8601String(),
              style: monoStyle.copyWith(
                color: theme.resources.textFillColorPrimary,
              ),
            ),
          ),
          // 2. Level
          SizedBox(width: 100, child: LogText(level: log.level)),
          // 3. Message
          Expanded(child: Text(log.message, style: monoStyle, softWrap: true)),
        ],
      ),
    );
  }
}

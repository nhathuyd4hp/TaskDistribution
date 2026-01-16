import 'dart:async';
import 'package:path/path.dart' as p;
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
import 'package:task_distribution/provider/run/run_filter.dart'; // Import quan trọng

class ExecutionLogPage extends StatefulWidget {
  const ExecutionLogPage({super.key});

  @override
  State<ExecutionLogPage> createState() => _ExecutionLogPageState();
}

class _ExecutionLogPageState extends State<ExecutionLogPage> {
  List<LogEntry> logs = [];
  StreamSubscription? _logSubscription;
  final ScrollController _scrollController = ScrollController();

  // Biến local để so sánh tránh loop
  String? _currentLoadedId;

  @override
  void initState() {
    super.initState();
    // 1. LOGIC TỰ ĐỘNG LOAD:
    // Lấy ID đang được chọn trong Provider (do trang Runs gửi sang)
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
      // Update lại local state để UI sync
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

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final filterProvider = context.watch<RunFilterProvider>(); // Watch filter
    final theme = FluentTheme.of(context);

    // Ưu tiên lấy ID từ Provider (Single Source of Truth)
    final displayId = filterProvider.selectedId;

    Run? currentRun;
    if (displayId != null) {
      try {
        currentRun = runProvider.runs.firstWhere((r) => r.id == displayId);
      } catch (_) {}
    }

    // Logic phụ: Nếu Provider đổi ID mà stream chưa đổi (trường hợp hiếm), connect lại
    if (displayId != null && displayId != _currentLoadedId) {
      // Dùng microtask để tránh lỗi setState trong build
      Future.microtask(() => _connectLogStream(displayId));
    }

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Execution Log'),
        commandBar: AutoSuggestBox<String>(
          placeholder: 'Search...',
          // Hiển thị ID đang chọn lên ô tìm kiếm
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
                // Khi chọn ở đây, update ngược lại vào Provider
                context.read<RunFilterProvider>().setSelectedId(run.id);
                // Hàm build sẽ chạy lại và trigger logic _connectLogStream ở trên
              },
            );
          }).toList(),
          onChanged: (text, reason) {
            if (reason == TextChangedReason.userInput && text.isEmpty) {
              // Clear
            }
          },
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          spacing: 16,
          children: [
            // 1. Info Panel
            if (displayId != null && currentRun != null)
              _buildRunInfoPanel(theme, currentRun),

            // 2. Log Table
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
            spacing: 50,
            children: [
              _buildInfoItem("Robot Name", run.robot, FluentIcons.robot),
              _buildInfoItem(
                "Started At",
                run.createdAt.toString().split('.')[0],
                FluentIcons.clock,
              ),
              _buildInfoItem(
                "Parameters",
                run.parameters ?? "",
                FluentIcons.variable,
              ),
              _buildInfoItem(
                "Result",
                run.status == "SUCCESS"
                    ? (run.result != null ? p.basename(run.result!) : "")
                    : (run.result ?? ""),
                FluentIcons.doc_library,
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
          SizedBox(width: 180, child: Text("TIMESTAMP", style: style)),
          SizedBox(width: 100, child: Text("LEVEL", style: style)),
          Expanded(child: Text("MESSAGE", style: style)),
          SizedBox(
            width: 125,
            child: run != null && run.result != null && run.status == "SUCCESS"
                ? FilledButton(
                    onPressed: () => context.read<RunProvider>().download(run),
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.download, size: 16),
                        Text("Download"),
                      ],
                    ),
                  )
                : null,
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
              child: LogText(level: log.level),
            ),
          ),
          Expanded(child: SelectableText(log.message, style: monoStyle)),
          const SizedBox(width: 100),
        ],
      ),
    );
  }
}

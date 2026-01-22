import "package:fluent_ui/fluent_ui.dart";
import "package:lottie/lottie.dart";
import "package:provider/provider.dart";
import "package:task_distribution/data/model/schedule.dart";
import "package:task_distribution/providers/schedule/schedule.dart";
import "package:task_distribution/providers/socket.dart";

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String nameContains = "";
  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final theme = FluentTheme.of(context);
    final server = context.watch<ServerProvider>();

    // Logic lọc dữ liệu
    final filtered = scheduleProvider.schedules.where((schedule) {
      final matchesName = nameContains.isEmpty
          ? true
          : schedule.name
                .split('.')
                .last
                .replaceAll("_", " ")
                .toLowerCase()
                .contains(nameContains.toLowerCase());
      return matchesName;
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text("Schedule"),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 300,
              child: TextBox(
                placeholder: 'Search...',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(FluentIcons.search),
                ),
                suffixMode: OverlayVisibilityMode.editing,
                suffix: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: () => setState(() => nameContains = ""),
                ),
                onChanged: (value) => setState(() => nameContains = value),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.resources.dividerStrokeColorDefault,
                  ),
                ),
                child: server.status == ConnectionStatus.connecting
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ProgressRing(),
                            const SizedBox(height: 12),
                            Text(
                              "Connecting to server...",
                              style: theme.typography.body,
                            ),
                          ],
                        ),
                      )
                    : server.status == ConnectionStatus.disconnected
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FluentIcons.plug_disconnected,
                              size: 48,
                              color: theme.resources.textFillColorSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text("Disconnected", style: theme.typography.title),
                            const SizedBox(height: 8),
                            Text(
                              server.errorMessage ??
                                  "Lost connection to server",
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Header của bảng
                          _buildTableHeader(theme),
                          const Divider(),
                          Expanded(
                            child: filtered.isEmpty
                                ? Center(
                                    child: Lottie.asset(
                                      'assets/lottie/NoData.json',
                                      width: 250,
                                      height: 250,
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: filtered.length,
                                    separatorBuilder: (ctx, i) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      return _buildTableRow(
                                        context,
                                        filtered[index],
                                        theme,
                                      );
                                    },
                                  ),
                          ),

                          // Footer thống kê
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor.withValues(
                                alpha: 0.5,
                              ),
                              border: Border(
                                top: BorderSide(
                                  color:
                                      theme.resources.dividerStrokeColorDefault,
                                ),
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Count: ${filtered.length}",
                              style: theme.typography.body,
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

  Widget _buildTableHeader(FluentThemeData theme) {
    final headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: theme.resources.textFillColorSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("ROBOT", style: headerStyle)),
          Expanded(flex: 1, child: Text("STATUS", style: headerStyle)),
          Expanded(flex: 2, child: Text("NEXT RUN", style: headerStyle)),
          Expanded(flex: 2, child: Text("START DATE", style: headerStyle)),
          Expanded(flex: 2, child: Text("END DATE", style: headerStyle)),
          Expanded(flex: 1, child: Text("DELETE", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    Schedule schedule,
    FluentThemeData theme,
  ) {
    // Format thời gian chạy kế tiếp
    final nextRun = schedule.nextRunTime != null
        ? schedule.nextRunTime.toString().split('.')[0]
        : "";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 1. Tên Robot
          Expanded(
            flex: 3,
            child: Text(
              schedule.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 1, child: _buildStatusBadge(schedule)),
          Expanded(
            flex: 2,
            child: Text(
              nextRun,
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              schedule.startDate.toString().split('.')[0],
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              schedule.endDate.toString().split('.')[0],
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(FluentIcons.delete, color: Color(0xffef314c)),
                onPressed: () => _handleDelete(context, schedule),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Schedule schedule) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (schedule.nextRunTime != null) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      icon = FluentIcons.clock;
    } else {
      bgColor = const Color(0xFFF5F5F5);
      textColor = const Color(0xFF616161);
      icon = FluentIcons.history;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 6),
            Text(
              schedule.nextRunTime != null ? "Active" : "Expired",
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Schedule schedule) async {
    final provider = context.read<ScheduleProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: BoxConstraints(maxWidth: 600),
        title: Text('Delete: ${schedule.name}'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      provider.deleteSchedule(schedule);
    }
  }
}

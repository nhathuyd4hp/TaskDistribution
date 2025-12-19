import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/empty_state.dart";
import "package:task_distribution/model/schedule.dart";
import "package:task_distribution/provider/schedule.dart";

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String nameContains = "";
  String statusFilter = "--";

  // Map hiển thị dropdown
  final Map<String, String> statusMap = {
    "--": "--",
    "Active": "Active",
    "Expired": "Expired",
  };

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final theme = FluentTheme.of(context);

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

      final filterValue = statusMap[statusFilter] ?? "--";
      final matchesStatus = filterValue == "--"
          ? true
          : schedule.status.toLowerCase() == filterValue.toLowerCase();

      return matchesName && matchesStatus;
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text("Schedule"),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 25,
          children: [
            // Dropdown Lọc trạng thái
            ComboBox<String>(
              value: statusFilter,
              items: statusMap.keys.map((e) {
                return ComboBoxItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => statusFilter = value);
              },
            ),
            Expanded(
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
                child: Column(
                  children: [
                    // Header của bảng
                    _buildTableHeader(theme),
                    const Divider(),
                    Expanded(
                      child: filtered.isEmpty
                          ? EmptyState()
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (ctx, i) => const Divider(),
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
                            color: theme.resources.dividerStrokeColorDefault,
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
          Expanded(flex: 3, child: Text("ROBOT NAME", style: headerStyle)),
          Expanded(flex: 2, child: Text("STATUS", style: headerStyle)),
          Expanded(flex: 3, child: Text("NEXT RUN", style: headerStyle)),
          Expanded(flex: 1, child: Text("ACTIONS", style: headerStyle)),
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
          Expanded(flex: 2, child: _buildStatusBadge(schedule)),
          Expanded(
            flex: 3,
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

    // Logic màu sắc cho Active/Expired
    if (schedule.status.toLowerCase() == 'active') {
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
              schedule.status,
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
        title: const Text('Confirm Delete'),

        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      provider.delete(schedule);
    }
  }
}

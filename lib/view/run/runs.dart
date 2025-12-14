import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/empty_state.dart";
import "package:task_distribution/view/run/widget/information_dialog.dart";
import "package:task_distribution/view/run/widget/logging_dialog.dart";
import "package:task_distribution/model/run.dart";
import "package:task_distribution/provider/run.dart";

class RunsManagement extends StatefulWidget {
  const RunsManagement({super.key});

  @override
  State<RunsManagement> createState() => _RunsManagementState();
}

class _RunsManagementState extends State<RunsManagement> {
  String nameContains = "";
  String statusFilter = "--";
  bool isAscending = true;

  final Map<String, String> statusMap = {
    "--": "--",
    "Pending": "Pending",
    "Failure": "Failure",
    "Success": "Success",
  };

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    final theme = FluentTheme.of(context);

    final filtered = runProvider.runs.where((run) {
      final matchesName = nameContains.isEmpty
          ? true
          : run.robot
                .split('.')
                .last
                .replaceAll("_", " ")
                .toLowerCase()
                .contains(nameContains.toLowerCase());

      final filterValue = statusMap[statusFilter] ?? "--";
      final matchesStatus = filterValue == "--"
          ? true
          : run.status.toLowerCase() == filterValue.toLowerCase();

      return matchesName && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      return isAscending
          ? a.createdAt.compareTo(b.createdAt) // ASC
          : b.createdAt.compareTo(a.createdAt); // DESC
    });

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Runs'),
        commandBar: Row(
          spacing: 25,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ComboBox<String>(
              placeholder: const Text("Status"),
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
                    // Header của bảng
                    _buildTableHeader(theme),
                    const Divider(),

                    // Nội dung bảng
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
          Expanded(flex: 3, child: Text("ID", style: headerStyle)),
          Expanded(flex: 2, child: Text("ROBOT NAME", style: headerStyle)),
          Expanded(flex: 1, child: Text("STATUS", style: headerStyle)),
          Expanded(
            flex: 2,
            child: Row(
              spacing: 5,
              children: [
                Text("RUN AT", style: headerStyle),
                IconButton(
                  icon: Icon(
                    isAscending
                        ? FluentIcons.sort_lines_ascending
                        : FluentIcons.sort_lines,
                  ),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text("ACTIONS", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, Run run, FluentThemeData theme) {
    final robotName = run.robot
        .replaceAll("_", " ")
        .split(".")
        .last
        .toUpperCase();
    final timeString = run.createdAt.toString().split('.')[0];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              run.id,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              robotName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 1, child: _buildStatusBadge(run)),
          Expanded(
            flex: 2,
            child: Text(
              timeString,
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
            child: Row(
              children: [
                Tooltip(
                  message: "Chi tiết",
                  child: IconButton(
                    icon: Icon(
                      FluentIcons.info,
                      color: theme.accentColor,
                      size: 18,
                    ),
                    onPressed: () async {
                      final provider = context.read<RunProvider>();
                      final result = await showDialog(
                        context: context,
                        builder: (ctx) =>
                            InformationDialog(dialogContext: ctx, run: run),
                      );
                      if (result != null) provider.download(run);
                    },
                  ),
                ),
                Tooltip(
                  message: "Log",
                  child: IconButton(
                    icon: const Icon(
                      FluentIcons.compliance_audit,
                      color: Color(0xFF2E7D32),
                      size: 18,
                    ), // Icon giống log file
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) =>
                            LoggingDialog(dialogContext: ctx, run: run),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị trạng thái (Success/Failure/Pending)
  Widget _buildStatusBadge(Run run) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text = run.status;

    switch (run.status.toLowerCase()) {
      case 'success':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = FluentIcons.check_mark;
        break;
      case 'failure':
      case 'error':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        icon = FluentIcons.error;
        break;
      case 'pending':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        icon = FluentIcons.clock;
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
        icon = FluentIcons.unknown;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              text,
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
}

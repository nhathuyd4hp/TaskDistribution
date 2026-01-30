import "dart:math";
import "package:fluent_ui/fluent_ui.dart";
import "package:lottie/lottie.dart";
import "package:provider/provider.dart";
import "package:task_distribution/providers/robot/robot_filter.dart";
import "package:task_distribution/screens/home/views/robot/widgets/run_form.dart";
import "package:task_distribution/screens/home/views/robot/widgets/schedule_form.dart";
import "package:task_distribution/data/model/robot.dart";
import "package:task_distribution/providers/robot/robot.dart";
import "package:task_distribution/providers/schedule/schedule.dart";
import "package:task_distribution/providers/socket.dart";

class RobotPage extends StatefulWidget {
  const RobotPage({super.key});

  @override
  State<RobotPage> createState() => _RobotPageState();
}

class _RobotPageState extends State<RobotPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<RobotFilterProvider>().nameQuery;
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final server = context.watch<ServerProvider>();

    // Search Box
    final searchBox = Selector<RobotFilterProvider, String>(
      selector: (_, provider) => provider.nameQuery,
      builder: (context, query, child) {
        if (_searchController.text != query) {
          _searchController.text = query;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
        return TextBox(
          placeholder: 'Search...',
          controller: _searchController,
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(FluentIcons.search),
          ),
          onChanged: (value) {
            context.read<RobotFilterProvider>().setNameContains(value);
          },
        );
      },
    );

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Robot'),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [SizedBox(width: 300, child: searchBox)],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(0),
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

          child: Consumer2<RobotProvider, RobotFilterProvider>(
            builder: (context, robotProvider, filterProvider, child) {
              if (server.status == ConnectionStatus.connecting) {
                return Center(
                  child: Column(
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
                  ),
                );
              }
              if (server.status == ConnectionStatus.disconnected) {
                return Center(
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
                        server.errorMessage ?? "Lost connection to server",
                        style: theme.typography.bodyStrong,
                      ),
                    ],
                  ),
                );
              }

              final fullFilteredList = filterProvider.apply(
                robotProvider.robots,
              );

              final paginatedList = filterProvider.paginate(fullFilteredList);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(theme),
                  const Divider(),

                  Expanded(
                    child: paginatedList.isEmpty
                        ? Center(
                            child: Lottie.asset(
                              'assets/lottie/Loading.json',
                              width: 250,
                              height: 250,
                            ),
                          )
                        : ListView.separated(
                            itemCount: paginatedList.length,
                            separatorBuilder: (ctx, i) => const Divider(),
                            itemBuilder: (context, index) {
                              return _buildTableRow(
                                context,
                                paginatedList[index],
                                theme,
                              );
                            },
                          ),
                  ),

                  _buildPaginationFooter(
                    context,
                    theme,
                    filterProvider,
                    fullFilteredList.length,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(
    BuildContext context,
    FluentThemeData theme,
    RobotFilterProvider provider,
    int totalItems,
  ) {
    final totalPages = (totalItems / provider.itemsPerPage).ceil();
    final currentPage = totalPages > 0
        ? min(provider.currentPage, totalPages)
        : 1;

    final startItem = totalItems == 0
        ? 0
        : (currentPage - 1) * provider.itemsPerPage + 1;
    final endItem = min(currentPage * provider.itemsPerPage, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Text("Rows per page:", style: theme.typography.caption),
          const SizedBox(width: 8),
          ComboBox<int>(
            value: provider.itemsPerPage,
            items: const [
              ComboBoxItem(value: 1, child: Text("1")),
              ComboBoxItem(value: 5, child: Text("5")),
              ComboBoxItem(value: 10, child: Text("10")),
              ComboBoxItem(value: 15, child: Text("15")),
              ComboBoxItem(value: 20, child: Text("20")),
            ],
            onChanged: (value) {
              if (value != null) provider.setItemsPerPage(value);
            },
          ),
          const Spacer(),
          Text(
            "$startItem-$endItem of $totalItems items",
            style: theme.typography.caption,
          ),
          const SizedBox(width: 16),

          IconButton(
            icon: const Icon(FluentIcons.chevron_left, size: 12),
            onPressed: currentPage > 1
                ? () => provider.setPage(currentPage - 1)
                : null,
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$currentPage / ${totalPages == 0 ? 1 : totalPages}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.chevron_right, size: 12),
            onPressed: currentPage < totalPages
                ? () => provider.setPage(currentPage + 1)
                : null,
          ),
        ],
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
          Expanded(child: Text("ROBOT", style: headerStyle)),
          SizedBox(width: 100, child: Text("STATUS", style: headerStyle)),
          SizedBox(width: 225, child: Text("ACTION", style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    Robot robot,
    FluentThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              robot.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: robot.active
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: robot.active
                        ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
                        : const Color(0xFFC62828).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  robot.active ? " Active " : "Inactive",
                  style: TextStyle(
                    color: robot.active
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 225,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 25,
              children: [
                FilledButton(
                  onPressed: () => _handleRun(context, robot),
                  child: Row(
                    spacing: 8,
                    children: const [
                      Icon(FluentIcons.play, size: 12),
                      Text("Run"),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => _handleSchedule(context, robot),
                  child: Row(
                    spacing: 8,
                    children: const [
                      Icon(FluentIcons.calendar, size: 12),
                      Text("Schedule"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRun(BuildContext context, Robot robot) async {
    final provider = context.read<RobotProvider>();
    final dynamic parameters = await showDialog(
      context: context,
      builder: (ctx) => RunForm(dialogContext: ctx, robot: robot),
    );
    if (parameters != null && parameters is Map<String, dynamic>) {
      provider.run(parameters);
    }
  }

  Future<void> _handleSchedule(BuildContext context, Robot robot) async {
    final provider = context.read<ScheduleProvider>();
    final dynamic schedule = await showDialog(
      context: context,
      builder: (ctx) => ScheduleForm(dialogContext: ctx),
    );
    if (schedule != null && schedule is Map<String, String>) {
      provider.setSchedule(robot, schedule);
    }
  }
}

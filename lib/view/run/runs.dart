import "dart:math"; // Import để tính toán phân trang
import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/shared/widgets/empty_state.dart";
import "package:task_distribution/shared/widgets/run_status_badge.dart";
import "package:task_distribution/provider/page.dart";
import "package:task_distribution/provider/run/run_filter.dart";
import "package:task_distribution/model/run.dart";
import "package:task_distribution/provider/run/run.dart";
import "package:task_distribution/provider/socket.dart";

class RunsPage extends StatefulWidget {
  const RunsPage({super.key});

  @override
  State<RunsPage> createState() => _RunsPageState();
}

class _RunsPageState extends State<RunsPage> {
  late TextEditingController _searchController;

  static const Map<String, String> statusMap = {
    "--": "",
    "Cancel": "Cancel",
    "Waiting": "Waiting",
    "Pending": "Pending",
    "Failure": "Failure",
    "Success": "Success",
  };

  @override
  void initState() {
    super.initState();
    final initialQuery = context.read<RunFilterProvider>().nameQuery;
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

    // Toolbar
    final toolbar = Row(
      children: [
        Selector<RunFilterProvider, String>(
          selector: (_, provider) => provider.statusQuery ?? "",
          builder: (context, query, child) {
            return ComboBox<String>(
              placeholder: const Text("Status"),
              value: query,
              items: statusMap.entries.map((e) {
                return ComboBoxItem(value: e.value, child: Text(e.key));
              }).toList(),
              onChanged: (value) {
                context.read<RunFilterProvider>().setStatus(value);
              },
            );
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Selector<RunFilterProvider, String>(
            selector: (_, provider) => provider.nameQuery,
            builder: (context, query, child) {
              if (_searchController.text != query) {
                _searchController.text = query;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length),
                );
              }
              return TextBox(
                controller: _searchController,
                placeholder: 'Search...',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(FluentIcons.search),
                ),
                suffixMode: OverlayVisibilityMode.editing,
                suffix: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: () {
                    context.read<RunFilterProvider>().setNameContains("");
                    _searchController.clear();
                  },
                ),
                onChanged: (value) {
                  context.read<RunFilterProvider>().setNameContains(value);
                },
              );
            },
          ),
        ),
      ],
    );

    return ScaffoldPage(
      header: PageHeader(
        padding: 0,
        title: const Text('Runs History'),
        commandBar: SizedBox(width: 500, child: toolbar),
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

          // CONSUMER: Xử lý cả Filter và Pagination
          child: Consumer2<RunProvider, RunFilterProvider>(
            builder: (context, runProvider, filterProvider, child) {
              if (server.status == ConnectionStatus.connecting) {
                return Center(
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
                      Text(server.errorMessage ?? "Lost connection to server"),
                    ],
                  ),
                );
              }

              // 1. Lấy toàn bộ danh sách đã filter (để đếm tổng)
              final fullFilteredList = filterProvider.apply(runProvider.runs);

              // 2. Cắt danh sách theo trang hiện tại (để hiển thị)
              final paginatedList = filterProvider.paginate(fullFilteredList);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(theme),
                  const Divider(),

                  // Hiển thị danh sách PAGINATED (chỉ 10 item)
                  Expanded(
                    child: paginatedList.isEmpty
                        ? const EmptyState()
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

                  // Footer Pagination: Truyền vào TỔNG SỐ item
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

  // --- FOOTER PHÂN TRANG (MỚI) ---
  Widget _buildPaginationFooter(
    BuildContext context,
    FluentThemeData theme,
    RunFilterProvider provider,
    int totalItems,
  ) {
    // Tính toán số liệu hiển thị
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
              ComboBoxItem(value: 10, child: Text("10")),
              ComboBoxItem(value: 20, child: Text("20")),
              ComboBoxItem(value: 30, child: Text("30")),
              ComboBoxItem(value: 50, child: Text("50")),
            ],
            onChanged: (value) {
              if (value != null) provider.setItemsPerPage(value);
            },
          ),

          const Spacer(),

          // 2. Hiển thị Range (1-10 of 50)
          Text(
            "$startItem-$endItem of $totalItems items",
            style: theme.typography.caption,
          ),
          const SizedBox(width: 16),

          // 3. Nút Previous
          IconButton(
            icon: const Icon(FluentIcons.chevron_left, size: 12),
            onPressed: currentPage > 1
                ? () => provider.setPage(currentPage - 1)
                : null,
          ),

          // 4. Số trang
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "$currentPage / ${totalPages == 0 ? 1 : totalPages}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // 5. Nút Next
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

  // --- Header Table ---
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
          SizedBox(width: 350, child: Text("ID", style: headerStyle)),
          Expanded(child: Text("ROBOT NAME", style: headerStyle)),
          SizedBox(width: 150, child: Text("STATUS", style: headerStyle)),
          SizedBox(
            width: 200,
            child: Row(
              children: [
                Text("RUN AT", style: headerStyle),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(FluentIcons.sort, size: 12),
                  onPressed: () =>
                      context.read<RunFilterProvider>().setIsAscending(),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: Text("ACTION", style: headerStyle),
          ),
        ],
      ),
    );
  }

  // --- Table Row ---
  Widget _buildTableRow(BuildContext context, Run run, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 350,
            child: SelectableText(
              run.id,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              run.robot,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 150,
            child: Align(
              alignment: Alignment.centerLeft,
              child: RunStatusBadge(run: run),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              run.createdAt.toString().split('.')[0],
              style: TextStyle(
                fontFamily: 'Consolas',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.resources.textFillColorSecondary,
              ),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(FluentIcons.info, color: theme.accentColor, size: 16),
              onPressed: () {
                context.read<RunFilterProvider>().setSelectedId(run.id);
                context.read<PageProvider>().setPage(AppPage.log);
              },
            ),
          ),
        ],
      ),
    );
  }
}

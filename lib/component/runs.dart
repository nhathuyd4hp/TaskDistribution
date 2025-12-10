import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/model/run.dart";
import "package:task_distribution/provider/run.dart";

class RunsManagement extends StatefulWidget {
  const RunsManagement({super.key});

  @override
  State<RunsManagement> createState() => _RunsManagementState();
}

class _RunsManagementState extends State<RunsManagement> {
  String nameFilter = "";
  String statusFilter = "--";
  List<Run> runs = [];

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Lịch sử chạy')),
            Expanded(
              child: Row(
                spacing: 25,
                children: [
                  Expanded(
                    child: TextBox(
                      placeholder: 'Lọc:',
                      expands: false,
                      onChanged: (value) {
                        setState(() {
                          nameFilter = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ComboBox<String>(
                      value: statusFilter,
                      items: ["--", "PENDING", "SUCCESS", "FAILURE"]
                          .map<ComboBoxItem<String>>((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          statusFilter = value ?? "--";
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: table(context, runProvider),
      ),
    );
  }

  Widget table(BuildContext context, RunProvider provider) {
    if (provider.isLoading) {
      return Center(child: ProgressRing());
    }
    if (provider.errorMessage != null) {
      final String errorMessage = provider.errorMessage!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.warning, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    final filtered = provider.runs.where((run) {
      // Lọc theo nameFilter
      final matchesName = nameFilter.isEmpty
          ? true
          : run.robot
                .split('.')
                .last
                .toLowerCase()
                .contains(nameFilter.toLowerCase());

      // Lọc theo statusFilter
      final matchesStatus = statusFilter == "--"
          ? true
          : run.status == statusFilter;

      return matchesName && matchesStatus;
    }).toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _listRuns(context, filtered[index]);
      },
    );
  }

  Widget _listRuns(BuildContext context, Run run) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: run.boxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 50,
            children: [
              Text(
                run.status,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                run.robot.replaceAll("_", " ").split(".").last.toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                run.createdAt,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          FilledButton(
            onPressed: run.status != "SUCCESS"
                ? null
                : () {
                    context.read<RunProvider>().download(run);
                  },
            child: const Text('Kết quả'),
          ),
        ],
      ),
    );
  }
}

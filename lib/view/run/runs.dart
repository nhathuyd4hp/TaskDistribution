import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/core/widget/text_box.dart";
import "package:task_distribution/model/run.dart";
import "package:task_distribution/provider/run.dart";
import "package:task_distribution/view/run/widget/information_dialog.dart";

class RunsManagement extends StatefulWidget {
  const RunsManagement({super.key});

  @override
  State<RunsManagement> createState() => _RunsManagementState();
}

class _RunsManagementState extends State<RunsManagement> {
  String nameContains = "";
  String statusFilter = "--";

  @override
  Widget build(BuildContext context) {
    final runProvider = context.watch<RunProvider>();

    return ScaffoldPage(
      content: Column(
        spacing: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử chạy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              Text(
                'Số lượng: ${runProvider.runs.length}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            spacing: 25,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xffffffff),
                  ),
                  child: WinTextBox(
                    prefix: WindowsIcon(WindowsIcons.search, size: 20.0),
                    placeholder: "Lọc theo tên",
                    onChanged: (value) {
                      setState(() {
                        nameContains = value;
                      });
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xffffffff),
                ),
                child: ComboBox<String>(
                  value: statusFilter,
                  items: ["--", "PENDING", "FAILURE", "SUCCESS"]
                      .map<ComboBoxItem<String>>((e) {
                        return ComboBoxItem<String>(value: e, child: Text(e));
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
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xffffffff),
              ),
              child: table(context, runProvider),
            ),
          ),
        ],
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
      // Lọc theo nameContains
      final matchesName = nameContains.isEmpty
          ? true
          : run.robot
                .split('.')
                .last
                .replaceAll("_", " ")
                .toLowerCase()
                .contains(nameContains.toLowerCase());
      // Lọc theo status
      final matchesStatus = statusFilter == "--"
          ? true
          : run.status == statusFilter;
      return matchesName && matchesStatus;
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _listRuns(context, filtered[index]);
      },
    );
  }

  Widget _listRuns(BuildContext context, Run run) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
        color: run.getColor(),
        border: Border.all(color: Color(0xffe5eaf1), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 25,
            children: [
              Text(
                run.status,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                run.createdAt.toString(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                run.robot.replaceAll("_", " ").split(".").last.toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          FilledButton(
            onPressed: () async {
              final provider = context.read<RunProvider>();
              final result = await showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return InformationDialog(
                    dialogContext: dialogContext,
                    run: run,
                  );
                },
              );
              if (result == null) return;
              provider.download(run);
            },
            child: const Text('Chi tiết'),
          ),
        ],
      ),
    );
  }
}

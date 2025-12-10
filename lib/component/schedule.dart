import "package:fluent_ui/fluent_ui.dart";
import "package:provider/provider.dart";
import "package:task_distribution/const/box_decoration.dart";
import "package:task_distribution/model/schedule.dart";
import "package:task_distribution/provider/schedule.dart";

class ScheduleManagement extends StatefulWidget {
  const ScheduleManagement({super.key});

  @override
  State<ScheduleManagement> createState() => _ScheduleManagementState();
}

class _ScheduleManagementState extends State<ScheduleManagement> {
  String nameFilter = "";
  String statusFilter = "--";
  List<Schedule> schedules = [];

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Lịch trình chạy')),
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
                      items: ["--", "EXPIRED", "ACTIVE"]
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
        child: table(context, scheduleProvider),
      ),
    );
  }

  Widget table(BuildContext context, ScheduleProvider provider) {
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
    final filtered = provider.schedules.where((schedule) {
      // Lọc theo nameFilter
      final matchesName = nameFilter.isEmpty
          ? true
          : schedule.name
                .split('.')
                .last
                .toLowerCase()
                .contains(nameFilter.toLowerCase());

      // Lọc theo statusFilter
      final matchesStatus = statusFilter == "--"
          ? true
          : schedule.status == statusFilter;

      return matchesName && matchesStatus;
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _listRuns(context, filtered[index]);
      },
    );
  }

  Widget _listRuns(BuildContext context, Schedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(16),
      decoration: deleteBoxDecorator,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 50,
            children: [
              Text(
                schedule.name
                    .replaceAll("_", " ")
                    .split(".")
                    .last
                    .toUpperCase(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                schedule.nextRunTime ?? "",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                schedule.status,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          FilledButton(
            onPressed: () {
              context.read<ScheduleProvider>().delete(schedule);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

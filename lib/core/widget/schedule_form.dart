import 'package:fluent_ui/fluent_ui.dart';

class ScheduleForm extends StatefulWidget {
  final BuildContext dialogContext;
  const ScheduleForm({super.key, required this.dialogContext});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  // Controller
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime runTime = DateTime.now();

  List<bool> dayOfWeek = [true, true, true, true, true, true, true];
  List<String> labelDayOfWeek = [
    "mon",
    "tue",
    "wed",
    "thu",
    "fri",
    "sat",
    "sun",
  ];

  //

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(maxWidth: 425, maxHeight: 550),
      title: Text('Lịch chạy'),
      content: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DatePicker(
              header: "Ngày bắt đầu:",
              headerStyle: TextStyle(fontWeight: FontWeight.w500),
              selected: startDate,
              onChanged: (time) {
                setState(() {
                  startDate = time;
                });
              },
            ),
          ),
          Expanded(
            child: DatePicker(
              header: "Ngày kết thúc:",
              headerStyle: TextStyle(fontWeight: FontWeight.w500),
              selected: endDate,
              onChanged: (time) {
                setState(() {
                  endDate = time;
                });
              },
            ),
          ),
          Expanded(
            child: TimePicker(
              header: "Giờ chạy:",
              headerStyle: TextStyle(fontWeight: FontWeight.w500),
              selected: DateTime.now(),
              onChanged: (time) {},
              hourFormat: HourFormat.HH,
            ),
          ),
          Expanded(
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ngày chạy:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Row(
                  spacing: 11,
                  children: List.generate(dayOfWeek.length, (i) {
                    return ToggleButton(
                      checked: dayOfWeek[i],
                      onChanged: (v) {
                        setState(() {
                          dayOfWeek[i] = v;
                        });
                      },
                      child: Text(labelDayOfWeek[i]),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        Button(
          child: Text('Hủy'),
          onPressed: () {
            Navigator.pop(widget.dialogContext, null);
          },
        ),
        FilledButton(
          child: Text('Cài'),
          onPressed: () {
            final Map<String, dynamic> result = {
              "hour": runTime.hour,
              "minute": runTime.minute,
              "day_of_week": [
                [
                  for (int i = 0; i < dayOfWeek.length; i++)
                    if (dayOfWeek[i]) labelDayOfWeek[i],
                ].join(','),
              ],
              "start_date": startDate.toString(),
              "end_date": endDate.toString(),
            };
            Navigator.pop(widget.dialogContext, result);
          },
        ),
      ],
    );
  }
}

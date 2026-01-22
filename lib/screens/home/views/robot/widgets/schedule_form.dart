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
  bool parametersInput = false;
  List<bool> dayOfWeek = [true, true, true, true, true, true, true];
  List<String> labelDayOfWeek = ["2", "3", "4", "5", "6", "7", "SU"];
  List<String> keyDayOfWeek = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
  //

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(maxWidth: 345, maxHeight: 500),
      title: Text('Schedule'),
      content: Column(
        spacing: 25,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            header: "From",
            headerStyle: TextStyle(fontWeight: FontWeight.w500),
            selected: startDate,
            onChanged: (time) {
              setState(() {
                startDate = time;
              });
            },
          ),
          DatePicker(
            header: "To",
            headerStyle: TextStyle(fontWeight: FontWeight.w500),
            selected: endDate,
            onChanged: (time) {
              setState(() {
                endDate = time;
              });
            },
          ),
          TimePicker(
            header: "Run at",
            headerStyle: TextStyle(fontWeight: FontWeight.w500),
            selected: DateTime.now(),
            onChanged: (time) {
              runTime = time;
            },
            hourFormat: HourFormat.HH,
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Day of week",
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
        ],
      ),
      actions: <Widget>[
        Button(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(widget.dialogContext, null);
          },
        ),
        FilledButton(
          child: Text('Confirm'),
          onPressed: () {
            final Map<String, dynamic> result = {
              "hour": runTime.hour,
              "minute": runTime.minute,
              "day_of_week": [
                for (int i = 0; i < dayOfWeek.length; i++)
                  if (dayOfWeek[i]) keyDayOfWeek[i],
              ].join(','),
              "start_date": startDate.toIso8601String(),
              "end_date": endDate.toIso8601String(),
            };
            final Map<String, String> schedule = result.map((key, value) {
              return MapEntry(key, value.toString());
            });
            Navigator.pop(widget.dialogContext, schedule);
          },
        ),
      ],
    );
  }
}

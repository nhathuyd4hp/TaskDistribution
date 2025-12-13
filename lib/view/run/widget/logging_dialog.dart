import 'package:fluent_ui/fluent_ui.dart';
import 'package:task_distribution/model/run.dart';

class LoggingDialog extends StatelessWidget {
  final BuildContext dialogContext;
  final Run run;

  const LoggingDialog({
    super.key,
    required this.dialogContext,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(maxHeight: 700),
      title: Text('Log'),
      content: Table(children: []),
      actions: <Widget>[
        Button(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(dialogContext, null);
          },
        ),
      ],
    );
  }
}

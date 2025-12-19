import 'package:fluent_ui/fluent_ui.dart';
import 'package:task_distribution/model/run.dart';

class InformationDialog extends StatelessWidget {
  final BuildContext dialogContext;
  final Run run;

  const InformationDialog({
    super.key,
    required this.dialogContext,
    required this.run,
  });

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(maxWidth: 550),
      title: Text('Run Details'),
      content: Table(
        children: [
          _buildTableRow('Robot:', run.robot),
          _buildTableRow('Status:', run.status),
          _buildTableRow('Parameter:', run.parameters ?? ""),
          _buildTableRow('Run at:', run.createdAt.toIso8601String()),
          _buildTableRow('Result:', run.result ?? ""),
        ],
      ),
      actions: <Widget>[
        run.status == "SUCCESS"
            ? FilledButton(
                child: Text('Result'),
                onPressed: () {
                  Navigator.pop(dialogContext, run);
                },
              )
            : Container(),
        Button(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(dialogContext, null);
          },
        ),
      ],
    );
  }
}

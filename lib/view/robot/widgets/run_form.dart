import 'package:fluent_ui/fluent_ui.dart';
import 'package:task_distribution/core/widget/text_box.dart';
import 'package:task_distribution/model/robot.dart';

class RunForm extends StatefulWidget {
  final BuildContext dialogContext;
  final Robot robot;
  // Constructor
  const RunForm({super.key, required this.dialogContext, required this.robot});
  @override
  State<RunForm> createState() => _RunFormState();
}

class _RunFormState extends State<RunForm> {
  final Map<String, dynamic> _controllers = {};

  Widget _buildInput(Parameter parameter) {
    if (parameter.name.toLowerCase().contains("date")) {
      return DatePicker(
        selected: _controllers[parameter.name] ?? DateTime.now(),
        onChanged: (value) {
          setState(() {
            _controllers[parameter.name] = value;
          });
        },
      );
    }
    return WinTextBox(
      onChanged: (value) {
        setState(() {
          _controllers[parameter.name] = value;
        });
      },
    );
  }

  Widget _buildForm() {
    if (widget.robot.parameters.isEmpty) {
      return Container();
    }
    return Column(
      spacing: 25,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.robot.parameters.map<Widget>((param) {
        return Row(
          spacing: 25,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                param.name.toUpperCase().replaceAll('_', " "),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(flex: 2, child: _buildInput(param)),
          ],
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    for (var p in widget.robot.parameters) {
      var defaultValue = p.defaultValue;
      if (p.annotation.toLowerCase().contains('date')) {
        _controllers[p.name] =
            DateTime.tryParse(defaultValue ?? "") ?? DateTime.now();
      } else {
        _controllers[p.name] = defaultValue ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Robot robot = widget.robot;
    return ContentDialog(
      constraints: BoxConstraints(
        maxWidth: 500,
        maxHeight: 225 + (robot.parameters.length * 25),
      ),
      title: Text('Parameter Input'),
      content: _buildForm(),
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
            final Map<String, String> data = _controllers.map((key, value) {
              return MapEntry(key, value.toString());
            });
            Navigator.pop(widget.dialogContext, {
              "name": robot.name,
              "parameters": data,
            });
          },
        ),
      ],
    );
  }
}

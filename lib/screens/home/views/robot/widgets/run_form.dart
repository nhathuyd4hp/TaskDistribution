import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:task_distribution/main.dart';
import 'package:task_distribution/data/model/api_response.dart';
import 'package:task_distribution/data/model/robot.dart';

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
  final Map<String, bool> _idLoading = {};
  late Future<Robot> _robotFuture;

  Widget _buildInput(Parameter parameter) {
    if (parameter.annotation.toLowerCase().contains("datetime.datetime")) {
      return DatePicker(
        selected: _controllers[parameter.name] ?? DateTime.now(),
        onChanged: (value) {
          setState(() {
            _controllers[parameter.name] = value;
          });
        },
      );
    }
    if (parameter.annotation.toLowerCase().contains("typing.literal")) {
      final content = parameter.annotation.substring(
        parameter.annotation.indexOf('[') + 1,
        parameter.annotation.lastIndexOf(']'),
      );
      final List<dynamic> items = content.split(',').map((e) {
        String clean = e.trim().replaceAll("'", "").replaceAll('"', "");
        return int.tryParse(clean) ?? clean;
      }).toList();

      return ComboBox<dynamic>(
        value: _controllers[parameter.name],
        items: items.map<ComboBoxItem<dynamic>>((e) {
          return ComboBoxItem<dynamic>(value: e, child: Text(e.toString()));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _controllers[parameter.name] = value;
          });
        },
        placeholder: Text(parameter.name),
      );
    }
    if (parameter.annotation.toLowerCase().contains("int")) {
      return NumberBox(
        placeholder: parameter.name,
        value: _controllers[parameter.name],
        onChanged: (value) {
          setState(() {
            _controllers[parameter.name] = value;
          });
        },
        mode: SpinButtonPlacementMode.inline,
      );
    }
    if (parameter.annotation.toLowerCase().contains("_io.bytesio")) {
      final String currentPath = _controllers[parameter.name]?.toString() ?? "";
      return Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextBox(
              placeholder: 'No file selected',
              readOnly: true,
              controller: TextEditingController(text: currentPath),
            ),
          ),
          FilledButton(
            onPressed: _idLoading[parameter.name] == true
                ? null
                : () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          dialogTitle: "Select a file",
                          lockParentWindow: true,
                          allowMultiple: false,
                          type: parameter.defaultValue == null
                              ? FileType.any
                              : FileType.custom,
                          allowedExtensions: parameter.defaultValue == null
                              ? null
                              : [parameter.defaultValue],
                        );
                    if (result == null) return;
                    setState(() {
                      _idLoading[parameter.name] = true;
                    });
                    final String filePath = result.files.single.path!;
                    final uri = Uri.parse(
                      "${RobotAutomation.backendUrl}/api/assets",
                    );
                    var request = http.MultipartRequest('POST', uri);
                    request.files.add(
                      await http.MultipartFile.fromPath('file', filePath),
                    );
                    var streamedResponse = await request.send();
                    var response = await http.Response.fromStream(
                      streamedResponse,
                    );
                    if (response.statusCode != 200) {
                      if (context.mounted) {
                        setState(() {
                          _controllers[parameter.name] = null;
                          _idLoading[parameter.name] = false;
                        });
                      }
                      return;
                    }
                    final Map<String, dynamic> responseJSON = jsonDecode(
                      response.body,
                    );
                    final apiResponse = APIResponse<String>.fromJson(
                      responseJSON,
                      (data) => data.toString(),
                    );
                    if (context.mounted) {
                      setState(() {
                        _controllers[parameter.name] = apiResponse.data;
                        _idLoading[parameter.name] = false;
                      });
                    }
                  },
            child: _idLoading[parameter.name] == true
                ? SizedBox(
                    width: 19,
                    height: 19,
                    child: const ProgressRing(strokeWidth: 2.5),
                  )
                : Icon(FluentIcons.file_request),
          ),
        ],
      );
    }
    if (parameter.annotation.toLowerCase().contains("bool")) {
      final bool isChecked = _controllers[parameter.name] == true;
      return Container(
        height: 32,
        alignment: Alignment.centerLeft,
        child: ToggleSwitch(
          checked: isChecked,
          content: Text(
            isChecked ? "Enabled" : "Disabled",
            style: TextStyle(
              color: isChecked ? Colors.blue : Colors.grey[100],
              fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _controllers[parameter.name] = value;
            });
          },
        ),
      );
    }
    return TextBox(
      placeholder: parameter.name,
      controller: TextEditingController(text: _controllers[parameter.name]),
      placeholderStyle: TextStyle(fontWeight: FontWeight.w500),
      style: TextStyle(fontWeight: FontWeight.w500),
      decoration: WidgetStatePropertyAll(
        BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      unfocusedColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onChanged: (value) {
        setState(() {
          _controllers[parameter.name] = value;
        });
      },
    );
  }

  Widget _buildForm(Robot robot) {
    if (robot.parameters.isEmpty) {
      return SizedBox(width: 0, height: 0);
    }
    return Column(
      spacing: 25,
      mainAxisAlignment: MainAxisAlignment.center,
      children: robot.parameters.map<Widget>((param) {
        return Row(
          spacing: 0,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                param.name.toUpperCase().replaceAll('_', " "),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(flex: 3, child: _buildInput(param)),
          ],
        );
      }).toList(),
    );
  }

  Future<Robot> _initRobotData() async {
    try {
      final result = await widget.robot.reGenerate();
      if (mounted) {
        setState(() {
          _idLoading.updateAll((key, value) => false);
        });
      }
      return result;
    } catch (e) {
      if (mounted) {
        setState(() {
          _idLoading.updateAll((key, value) => false);
        });
      }
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _robotFuture = _initRobotData();
    for (var p in widget.robot.parameters) {
      // ------ //
      if (p.annotation.toLowerCase().contains("type.api")) {
        _idLoading[p.name] = true;
      } else {
        _idLoading[p.name] = false;
      }
      // ------ //
      var defaultValue = p.defaultValue;
      if (p.annotation.toLowerCase().contains('datetime.datetime')) {
        _controllers[p.name] =
            DateTime.tryParse(defaultValue ?? "") ?? DateTime.now();
      } else if (p.annotation.toLowerCase().contains('int')) {
        _controllers[p.name] = defaultValue;
      } else if (p.annotation.toLowerCase().contains('_io.bytesio')) {
        _controllers[p.name] = null;
      } else if (p.annotation.toLowerCase().contains('bool')) {
        _controllers[p.name] = defaultValue
            ? bool.parse(defaultValue.toString())
            : false;
      } else {
        _controllers[p.name] = defaultValue ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Robot robot = widget.robot;

    return FutureBuilder<Robot>(
      future: _robotFuture,
      builder: (context, snapshot) {
        final bool hasError = snapshot.hasError;
        final bool hasData = snapshot.hasData;

        return ContentDialog(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: 200 + (robot.parameters.length * 50),
          ),
          title: Text(robot.name),
          content: () {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: ProgressBar());
            } else if (hasError) {
              return Text("${snapshot.error}");
            } else if (hasData) {
              return _buildForm(snapshot.data!);
            }
            return const SizedBox.shrink();
          }(),
          actions: <Widget>[
            Button(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(widget.dialogContext, null);
              },
            ),
            if (!hasError && hasData)
              FilledButton(
                onPressed: _idLoading.values.any((e) => e)
                    ? null
                    : () {
                        final Map<String, String> data = _controllers.map((
                          key,
                          value,
                        ) {
                          return MapEntry(key, value.text);
                        });

                        Navigator.pop(widget.dialogContext, {
                          "name": robot.name,
                          "parameters": data,
                        });
                      },
                child: _idLoading.values.any((e) => e)
                    ? const Text('Waiting...')
                    : const Text('Run'),
              ),
          ],
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:task_distribution/main.dart';
import 'package:task_distribution/data/model/api_response.dart';
import 'package:task_distribution/data/model/robot.dart';
import 'package:url_launcher/url_launcher.dart';

class RunForm extends StatefulWidget {
  final BuildContext dialogContext;
  final Robot robot;

  const RunForm({super.key, required this.dialogContext, required this.robot});

  @override
  State<RunForm> createState() => _RunFormState();
}

class _RunFormState extends State<RunForm> {
  final Map<String, dynamic> _controllers = {};
  final Map<String, bool> _idLoading = {};
  late Future<Robot> _robotFuture;
  bool runInFuture = false;
  DateTime? runOn;
  DateTime? runAt;

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
      final bool isAsset = parameter.annotation.toLowerCase().contains(
        "src.core.type.asset",
      );
      if (items.length == 1) {
        final singleValue = items.first;
        if (_controllers[parameter.name] != singleValue && !isAsset) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _controllers[parameter.name] = singleValue;
              });
            }
          });
        }
        return Row(
          spacing: 8,
          children: [
            if (isAsset) ...[
              (() {
                final bool hasFile = RegExp(
                  r'^([a-zA-Z0-9._-]+)\?objectName=.+$',
                ).hasMatch(_controllers[parameter.name].toString());
                return Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      if (hasFile) ...[
                        IconButton(
                          icon: Icon(FluentIcons.delete, color: Colors.red),
                          onPressed: () async {
                            if (_controllers[parameter.name] == null) return;
                            final Uri uri = Uri.parse(parameter.defaultValue!);
                            final String bucket =
                                uri.queryParameters['bucket']?.isNotEmpty ==
                                    true
                                ? uri.queryParameters['bucket']!
                                : uri.path;
                            final String objectName =
                                uri.queryParameters['objectName'] ?? "";
                            final String deleteUrl =
                                "${RobotAutomation.backendUrl}/api/assets/${bucket.toLowerCase()}?objectName=$objectName";
                            try {
                              setState(() => _idLoading[parameter.name] = true);
                              final response = await http.delete(
                                Uri.parse(deleteUrl),
                              );
                              if (response.statusCode == 200) {
                                setState(() {
                                  _controllers[parameter.name] = null;
                                });
                              }
                            } finally {
                              setState(
                                () => _idLoading[parameter.name] = false,
                              );
                            }
                          },
                        ),
                        // NÚT VIEW FILE
                        Expanded(
                          child: TextBox(
                            placeholder: _controllers[parameter.name]
                                .toString()
                                .split("=")
                                .last,
                            placeholderStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            readOnly: true,
                            enabled: true,
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            if (_controllers[parameter.name] == null) return;
                            final Uri uri = Uri.parse(
                              _controllers[parameter.name],
                            );
                            final String bucket = uri.path;
                            final String? objectName =
                                uri.queryParameters['objectName'];
                            final String previewURL =
                                "${RobotAutomation.backendUrl}/api/assets/$bucket?objectName=$objectName&preview=True";
                            await launchUrl(Uri.parse(previewURL));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.view, size: 16),
                              SizedBox(width: 8),
                              Text("View File"),
                            ],
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: TextBox(
                            placeholder: 'File Not Found',
                            placeholderStyle: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                            readOnly: true,
                            enabled: true,
                          ),
                        ),
                      ],

                      // NÚT UPLOAD (Nằm cuối Row)
                      FilledButton(
                        onPressed: _idLoading[parameter.name] == true
                            ? null
                            : () async {
                                final uri = Uri.parse(parameter.defaultValue);
                                final String bucket =
                                    uri.queryParameters['bucket']?.isNotEmpty ==
                                        true
                                    ? uri.queryParameters['bucket']!
                                    : uri.path;

                                final String? objectName =
                                    uri.queryParameters['objectName'];
                                if (objectName == null) {
                                  return;
                                }
                                String extension = objectName.split('.').last;
                                FilePickerResult? result = await FilePicker
                                    .platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: [extension],
                                    );

                                if (result == null) return;
                                setState(
                                  () => _idLoading[parameter.name] = true,
                                );

                                try {
                                  final String filePath =
                                      result.files.single.path!;
                                  final uploadUri =
                                      Uri.parse(
                                        "${RobotAutomation.backendUrl}/api/assets",
                                      ).replace(
                                        queryParameters: {
                                          'bucket': bucket,
                                          'objectName': objectName,
                                        },
                                      );

                                  var request = http.MultipartRequest(
                                    'POST',
                                    uploadUri,
                                  );
                                  request.files.add(
                                    await http.MultipartFile.fromPath(
                                      'file',
                                      filePath,
                                    ),
                                  );
                                  var response = await http.Response.fromStream(
                                    await request.send(),
                                  );

                                  if (response.statusCode == 200) {
                                    final apiResponse =
                                        APIResponse<String>.fromJson(
                                          jsonDecode(response.body),
                                          (data) => data.toString(),
                                        );
                                    setState(() {
                                      _controllers[parameter.name] = apiResponse
                                          .data; // Cập nhật state để Row rebuild
                                    });
                                  }
                                } finally {
                                  setState(
                                    () => _idLoading[parameter.name] = false,
                                  );
                                }
                              },
                        child: _idLoading[parameter.name] == true
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: ProgressRing(strokeWidth: 2.5),
                              )
                            : const Icon(FluentIcons.file_request, size: 18),
                      ),
                    ],
                  ),
                );
              }()), // Sử dụng Immediately Invoked Function Expression (IIFE) để xử lý logic nội bộ
            ],
          ],
        );
      }

      return ComboBox<dynamic>(
        value: _controllers[parameter.name],
        items: items.map<ComboBoxItem<dynamic>>((e) {
          return ComboBoxItem<dynamic>(
            value: e,
            child: Text(e.toString().replaceAll(r'\u3000', ' ')),
          );
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
      final String? currentVal = _controllers[parameter.name]?.toString();
      final bool hasFile = currentVal != null && currentVal.isNotEmpty;
      return Row(
        spacing: 8,
        children: [
          Expanded(
            child: hasFile
                ? Row(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _controllers[parameter.name] = null;
                          });
                        },
                      ),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            if (context.mounted) {
                              final String previewURL =
                                  "${RobotAutomation.backendUrl}/api/assets/$currentVal&preview=True";
                              await launchUrl(Uri.parse(previewURL));
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.view, size: 16),
                              SizedBox(width: 8),
                              Text("View File"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const TextBox(
                    placeholder: 'No file selected',
                    readOnly: true,
                    enabled: false,
                    prefix: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(FluentIcons.info, size: 14),
                    ),
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
                : Icon(FluentIcons.file_request, size: 18),
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
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: robot.parameters.map<Widget>((param) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoLabel(
              label: param.name
                  .split('_')
                  .map(
                    (e) => e.isNotEmpty
                        ? '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}'
                        : '',
                  )
                  .join(' '),
              labelStyle: TextStyle(fontWeight: FontWeight.w500),
              child: _buildInput(param),
            ),
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
      for (var p in result.parameters) {
        if (p.annotation.toLowerCase().contains("type.api")) {
          _idLoading[p.name] = true;
        } else {
          _idLoading[p.name] = false;
        }
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
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      robot.name,
                      style: const TextStyle(
                        fontSize: 22.5,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ToggleSwitch(
                    checked: runInFuture,
                    onChanged: (value) {
                      setState(() {
                        runInFuture = value;
                        if (value) {
                          runOn = DateTime.now();
                          runAt = DateTime.now();
                        } else {
                          runOn = null;
                          runAt = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                size: double.infinity,
                style: DividerThemeData(
                  thickness: 0.5,
                  decoration: BoxDecoration(
                    color: FluentTheme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          content: hasData
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (robot.parameters.isNotEmpty) ...[
                        const Text(
                          "Input Parameters",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildForm(snapshot.data!),
                        const SizedBox(height: 20),
                      ],

                      if (runInFuture) ...[
                        Divider(
                          size: double.infinity,
                          style: DividerThemeData(
                            thickness: 0.5,
                            decoration: BoxDecoration(
                              color: FluentTheme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Execution Time",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InfoLabel(
                                label: "Run on",
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                child: DatePicker(
                                  selected: runOn,
                                  onChanged: (date) =>
                                      setState(() => runOn = date),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InfoLabel(
                                label: "Run at",
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                child: TimePicker(
                                  selected: runAt,
                                  hourFormat: HourFormat.HH,
                                  onChanged: (time) =>
                                      setState(() => runAt = time),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )
              : (hasError
                    ? Center(child: Text("Error: ${snapshot.error}"))
                    : const Center(child: ProgressBar())),
          actions: <Widget>[
            Button(
              onPressed: () {
                Navigator.pop(widget.dialogContext, null);
              },
              child: const Text('Cancel'),
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
                          if (value is DateTime) {
                            return MapEntry(
                              key,
                              value.toUtc().toIso8601String(),
                            );
                          }
                          return MapEntry(key, value?.toString() ?? "");
                        });
                        final DateTime? eta =
                            (runInFuture && runOn != null && runAt != null)
                            ? DateTime(
                                runOn!.year,
                                runOn!.month,
                                runOn!.day,
                                runAt!.hour,
                                runAt!.minute,
                                runAt!.second,
                              )
                            : null;
                        Navigator.pop(widget.dialogContext, {
                          "name": robot.name,
                          "parameters": data,
                          "eta": eta?.toUtc().toIso8601String(),
                        });
                      },
                child: _idLoading.values.any((e) => e)
                    ? const Text('Waiting...')
                    : Text(runInFuture ? 'Schedule' : 'Run Now'),
              ),
          ],
        );
      },
    );
  }
}

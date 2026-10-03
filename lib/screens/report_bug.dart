import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _form = GlobalKey<FormState>();
  final id = TextEditingController();
  final title = TextEditingController();
  final steps = TextEditingController();
  final expected = TextEditingController();
  final actual = TextEditingController();
  final evidence = TextEditingController();
  final remarks = TextEditingController();
  String module = modules.first, severity = 'Medium', priority = 'Medium', status = 'Open';
  bool _idSet = false;

  @override
  void dispose() {
    for (final c in [id, title, steps, expected, actual, evidence, remarks]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    if (!_idSet) {
      id.text = store.nextBugId();
      _idSet = true;
    }
    return FormShell(
      title: 'Report Bug',
      subtitle: 'Describe a reproducible issue',
      icon: Icons.bug_report,
      formKey: _form,
      saveLabel: 'Submit Bug',
      onSave: () async {
        if (!_form.currentState!.validate()) {
          showOk(context, 'Please fill in the required fields', error: true);
          return;
        }
        store.addBug(Bug(
          id: id.text.trim(),
          title: title.text.trim(),
          module: module,
          steps: steps.text.trim(),
          expected: expected.text.trim(),
          actual: actual.text.trim(),
          severity: severity,
          priority: priority,
          status: status,
          evidence: evidence.text.trim(),
          remarks: remarks.text.trim(),
        ));
        await showSuccessDialog(context, 'Bug reported', '${id.text.trim()} was added to the bug tracker.');
        if (mounted) Navigator.pop(context);
      },
      children: [
        tf(id, 'Bug ID', Icons.tag, required: true, validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Bug ID cannot be empty';
          if (store.bugIdExists(v)) return 'This Bug ID already exists';
          return null;
        }),
        tf(title, 'Title', Icons.title, required: true, hint: 'Short, clear summary'),
        dd('Module', Icons.folder_open, module, modules, (v) => setState(() => module = v)),
        tf(steps, 'Steps to Reproduce', Icons.format_list_numbered, required: true, lines: 4),
        tf(expected, 'Expected Result', Icons.flag, required: true, lines: 2),
        tf(actual, 'Actual Result', Icons.report_problem, required: true, lines: 2),
        dd('Severity', Icons.priority_high, severity, severities, (v) => setState(() => severity = v)),
        dd('Priority', Icons.flag, priority, priorities, (v) => setState(() => priority = v)),
        dd('Status', Icons.timelapse, status, bugStatuses, (v) => setState(() => status = v)),
        tf(evidence, 'Screenshot / Video Path', Icons.attach_file, hint: 'screenshots/bug-001.png or video link'),
        tf(remarks, 'Remarks', Icons.notes, lines: 2),
      ],
    );
  }
}

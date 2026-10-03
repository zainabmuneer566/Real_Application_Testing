import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';

class AddTestCaseScreen extends StatefulWidget {
  const AddTestCaseScreen({super.key});

  @override
  State<AddTestCaseScreen> createState() => _AddTestCaseScreenState();
}

class _AddTestCaseScreenState extends State<AddTestCaseScreen> {
  final _form = GlobalKey<FormState>();
  final id = TextEditingController();
  final title = TextEditingController();
  final pre = TextEditingController();
  final steps = TextEditingController();
  final data = TextEditingController();
  final expected = TextEditingController();
  final actual = TextEditingController();
  final remarks = TextEditingController();
  String module = modules.first, status = 'Not Tested', priority = 'Medium', day = 'Day 2';
  DateTime date = DateTime.now();
  bool _idSet = false;

  @override
  void dispose() {
    for (final c in [id, title, pre, steps, data, expected, actual, remarks]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    if (!_idSet) {
      id.text = store.nextTestCaseId();
      _idSet = true;
    }
    return FormShell(
      title: 'Add Test Case',
      subtitle: 'Document one functional test',
      icon: Icons.add_task,
      formKey: _form,
      saveLabel: 'Save Test Case',
      onSave: () {
        if (!_form.currentState!.validate()) {
          showOk(context, 'Please fix the highlighted fields', error: true);
          return;
        }
        store.addTestCase(TestCase(
          id: id.text.trim(),
          title: title.text.trim(),
          module: module,
          preconditions: pre.text.trim(),
          steps: steps.text.trim(),
          data: data.text.trim(),
          expected: expected.text.trim(),
          actual: actual.text.trim(),
          status: status,
          priority: priority,
          remarks: remarks.text.trim(),
          day: day,
          date: date,
        ));
        showOk(context, 'Test case added successfully');
        Navigator.pop(context);
      },
      children: [
        tf(id, 'Test Case ID', Icons.tag, required: true, hint: 'TC-004', validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Test Case ID cannot be empty';
          if (store.tcIdExists(v)) return 'This ID already exists';
          return null;
        }),
        tf(title, 'Title', Icons.title, required: true, hint: 'Login with valid credentials'),
        dd('Module', Icons.folder_open, module, modules, (v) => setState(() => module = v)),
        tf(pre, 'Preconditions', Icons.rule, lines: 2),
        tf(steps, 'Test Steps', Icons.format_list_numbered, lines: 4, hint: '1. Open the page\n2. Click ...'),
        tf(data, 'Test Data', Icons.dataset, lines: 2, hint: 'Use dummy data only'),
        tf(expected, 'Expected Result', Icons.flag, required: true, lines: 2),
        tf(actual, 'Actual Result', Icons.fact_check, lines: 2),
        dd('Status', Icons.verified, status, tcStatuses, (v) => setState(() => status = v)),
        dd('Priority', Icons.priority_high, priority, priorities, (v) => setState(() => priority = v)),
        dd('Day', Icons.event_note, day, days, (v) => setState(() => day = v)),
        dateField(context, 'Date tested', date, (d) => setState(() => date = d)),
        tf(remarks, 'Remarks', Icons.notes, lines: 2),
      ],
    );
  }
}

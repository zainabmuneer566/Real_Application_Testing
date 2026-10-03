import 'package:flutter/material.dart';
import 'models.dart';
import 'ui.dart';

/// Holds all app data in memory. Screens listen to it and rebuild automatically.
/// (Data resets when the app restarts - add shared_preferences/sqflite later to persist.)
class QaStore extends ChangeNotifier {
  final List<TestCase> testCases = [
    TestCase(
      id: 'TC-001',
      title: 'Open the app and check the home screen loads (sample)',
      module: 'Navigation',
      preconditions: 'Browser open, internet connected',
      steps: '1. Open the app URL\n2. Wait for the page to load',
      data: 'N/A',
      expected: 'Home / login screen loads without errors',
      actual: 'Loaded correctly',
      status: 'Passed',
      priority: 'High',
      remarks: 'SAMPLE - replace with your own test case',
    ),
    TestCase(
      id: 'TC-002',
      title: 'Submit a form with empty required fields (sample)',
      module: 'Forms',
      steps: '1. Open a form\n2. Leave required fields empty\n3. Press submit',
      expected: 'Friendly validation message is shown',
      actual: 'No message shown',
      status: 'Failed',
      priority: 'Medium',
      remarks: 'SAMPLE - replace with your own test case',
      day: 'Day 3',
    ),
    TestCase(
      id: 'TC-003',
      title: 'Check layout on a mobile viewport (sample)',
      module: 'Responsive',
      expected: 'Layout adapts without horizontal scroll',
      status: 'Not Tested',
      priority: 'Low',
      remarks: 'SAMPLE - replace with your own test case',
    ),
  ];

  final List<Bug> bugs = [
    Bug(
      id: 'BUG-001',
      title: 'Missing validation message on empty form (sample)',
      module: 'Forms',
      steps: '1. Open form\n2. Leave fields empty\n3. Submit',
      expected: 'Validation message appears',
      actual: 'Nothing happens',
      severity: 'High',
      priority: 'High',
      status: 'Open',
      evidence: 'screenshots/bug-001.png',
      remarks: 'SAMPLE - replace with your own bug',
    ),
  ];

  final List<RetestEntry> retests = [
    RetestEntry(
      refId: 'BUG-001',
      originalStatus: 'Open',
      remarks: 'SAMPLE - update after the developer fixes it',
    ),
  ];

  final List<QaNote> notes = [
    QaNote(
      category: 'UI/UX',
      title: 'Sample observation',
      body: 'Write general observations here (spacing, colors, icons, readability...).',
    ),
  ];

  final List<ApiTest> apiTests = [];

  final List<DeepCategory> deep = [
    DeepCategory(
      title: 'Boundary Testing',
      description: 'Check values at and around the allowed limits.',
      icon: Icons.straighten,
      color: C.primary,
      items: ['Minimum value', 'Maximum value', 'Just below minimum', 'Just above maximum'],
    ),
    DeepCategory(
      title: 'Negative Testing',
      description: 'Try to break the app with wrong or unexpected input.',
      icon: Icons.remove_circle_outline,
      color: C.red,
      items: ['Invalid data', 'Wrong format', 'Invalid credentials', 'Unsupported input'],
    ),
    DeepCategory(
      title: 'Empty Field Testing',
      description: 'Submit forms with required and optional fields left empty.',
      icon: Icons.check_box_outline_blank,
      color: C.orange,
      items: ['Empty required fields', 'Empty optional fields'],
    ),
    DeepCategory(
      title: 'Duplicate Data',
      description: 'Create the same record twice and see how the app reacts.',
      icon: Icons.content_copy,
      color: C.pink,
      items: ['Duplicate customer', 'Duplicate transaction', 'Duplicate records'],
    ),
    DeepCategory(
      title: 'Navigation Testing',
      description: 'Move around the app in every way a user could.',
      icon: Icons.alt_route,
      color: C.teal,
      items: ['Back button', 'Navigation flow', 'Broken links', 'Unexpected redirects'],
    ),
    DeepCategory(
      title: 'Responsive Testing',
      description: 'Check the layout on different screen sizes.',
      icon: Icons.devices,
      color: C.blue,
      items: ['Desktop', 'Tablet', 'Mobile'],
    ),
    DeepCategory(
      title: 'Regression Testing',
      description: 'Make sure old features still work after fixes.',
      icon: Icons.sync,
      color: C.violet,
      items: ['Previously fixed functionality', 'Previously tested functionality', 'Re-tested bugs'],
    ),
  ];

  void touch() => notifyListeners();

  // ---- statistics ----
  int get total => testCases.length;
  int countTc(String s) => testCases.where((t) => t.status == s).length;
  int get criticalBugs => bugs.where((b) => b.severity == 'Critical').length;
  int get openBugs => bugs.where((b) => ['Open', 'In Progress', 'Reopened'].contains(b.status)).length;
  int get retestedCount => retests.where((r) => r.retestStatus == 'Completed').length;
  int get deepDone => deep.where((d) => d.status == 'Completed').length;

  // ---- id helpers ----
  String _nextId(String prefix, Iterable<String> existing) {
    var n = existing.length + 1;
    while (existing.contains('$prefix-${n.toString().padLeft(3, '0')}')) {
      n++;
    }
    return '$prefix-${n.toString().padLeft(3, '0')}';
  }

  String nextTestCaseId() => _nextId('TC', testCases.map((t) => t.id));
  String nextBugId() => _nextId('BUG', bugs.map((b) => b.id));
  bool tcIdExists(String id) => testCases.any((t) => t.id.toLowerCase() == id.trim().toLowerCase());
  bool bugIdExists(String id) => bugs.any((b) => b.id.toLowerCase() == id.trim().toLowerCase());

  // ---- test cases ----
  void addTestCase(TestCase t) {
    testCases.insert(0, t);
    notifyListeners();
  }

  void setTcStatus(TestCase t, String s) {
    t.status = s;
    notifyListeners();
  }

  void deleteTestCase(TestCase t) {
    testCases.remove(t);
    notifyListeners();
  }

  // ---- bugs ----
  void addBug(Bug b) {
    bugs.insert(0, b);
    notifyListeners();
  }

  void setBugStatus(Bug b, String s) {
    final old = b.status;
    b.status = s;
    if (s == 'Retest' && !retests.any((r) => r.refId == b.id)) {
      retests.insert(0, RetestEntry(refId: b.id, originalStatus: old));
    }
    notifyListeners();
  }

  void deleteBug(Bug b) {
    bugs.remove(b);
    notifyListeners();
  }

  // ---- regression ----
  List<String> get allRefIds => [...bugs.map((b) => b.id), ...testCases.map((t) => t.id)];

  String originalStatusOf(String id) {
    for (final b in bugs) {
      if (b.id == id) return b.status;
    }
    for (final t in testCases) {
      if (t.id == id) return t.status;
    }
    return 'Unknown';
  }

  void addRetest(RetestEntry r) {
    retests.insert(0, r);
    notifyListeners();
  }

  void deleteRetest(RetestEntry r) {
    retests.remove(r);
    notifyListeners();
  }

  // ---- notes / api ----
  void addNote(QaNote n) {
    notes.insert(0, n);
    notifyListeners();
  }

  void deleteNote(QaNote n) {
    notes.remove(n);
    notifyListeners();
  }

  void addApi(ApiTest a) {
    apiTests.insert(0, a);
    notifyListeners();
  }

  void deleteApi(ApiTest a) {
    apiTests.remove(a);
    notifyListeners();
  }

  /// Removes the sample entries so you can start with your real data.
  void clearAll() {
    testCases.clear();
    bugs.clear();
    retests.clear();
    notes.clear();
    apiTests.clear();
    notifyListeners();
  }
}

class QaScope extends InheritedNotifier<QaStore> {
  QaScope({super.key, required QaStore store, required super.child}) : super(notifier: store);

  static QaStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QaScope>()!.notifier!;
}

import 'package:flutter/material.dart';
import 'screens/api_testing.dart';
import 'screens/bugs.dart';
import 'screens/dashboard.dart';
import 'screens/deep_qa.dart';
import 'screens/notes.dart';
import 'screens/regression.dart';
import 'screens/test_cases.dart';
import 'store.dart';
import 'ui.dart';

void main() => runApp(QaScope(store: QaStore(), child: const QaApp()));

class QaApp extends StatelessWidget {
  const QaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQA QA Dashboard',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Shell(),
    );
  }
}

class _Dest {
  final String label;
  final IconData icon;
  const _Dest(this.label, this.icon);
}

const _dests = [
  _Dest('Dashboard', Icons.dashboard),
  _Dest('Test Cases', Icons.assignment),
  _Dest('Bug Tracker', Icons.bug_report),
  _Dest('Day 3 Deep QA', Icons.science),
  _Dest('Regression', Icons.sync),
  _Dest('QA Notes', Icons.sticky_note_2),
  _Dest('API Testing', Icons.api),
];

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  void go(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final body = IndexedStack(index: index, children: [
      DashboardScreen(onNavigate: go),
      const TestCasesScreen(),
      const BugsScreen(),
      const DeepQaScreen(),
      const RegressionScreen(),
      const NotesScreen(),
      const ApiScreen(),
    ]);
    final content = Center(
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: body),
    );

    if (wide) {
      return Scaffold(
        body: Row(children: [
          SizedBox(width: 250, child: _SideMenu(selected: index, onSelect: go)),
          Expanded(child: content),
        ]),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_dests[index].label, style: const TextStyle(fontWeight: FontWeight.w800)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: C.gradient)),
      ),
      drawer: Drawer(
        child: Builder(
          builder: (ctx) => _SideMenu(
            selected: index,
            onSelect: (i) {
              Navigator.pop(ctx);
              go(i);
            },
          ),
        ),
      ),
      body: content,
    );
  }
}

class _SideMenu extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _SideMenu({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 22),
          decoration: const BoxDecoration(gradient: C.gradient),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Icon(Icons.science, color: Colors.white, size: 34),
            SizedBox(height: 10),
            Text('QA Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            Text('SQA Internship', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        Expanded(
          child: ListView(padding: const EdgeInsets.all(12), children: [
            for (var i = 0; i < _dests.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  selected: i == selected,
                  selectedTileColor: C.primary.withOpacity(.10),
                  selectedColor: C.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(_dests[i].icon),
                  title: Text(_dests[i].label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () => onSelect(i),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

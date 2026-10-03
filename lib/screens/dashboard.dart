import 'package:flutter/material.dart';
import '../store.dart';
import '../ui.dart';
import 'add_test_case.dart';
import 'notes.dart';
import 'report_bug.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final s = QaScope.of(context);
    final executed = s.countTc('Passed') + s.countTc('Failed') + s.countTc('Blocked');
    final executedRatio = s.total == 0 ? 0.0 : executed / s.total;
    final passRatio = executed == 0 ? 0.0 : s.countTc('Passed') / executed;
    final day2 = s.testCases.where((t) => t.day == 'Day 2').length;
    final day3 = s.testCases.where((t) => t.day == 'Day 3').length;

    final stats = [
      _Stat('Total Test Cases', s.total, Icons.assignment, C.primary),
      _Stat('Passed', s.countTc('Passed'), Icons.check_circle, C.green),
      _Stat('Failed', s.countTc('Failed'), Icons.cancel, C.red),
      _Stat('Blocked', s.countTc('Blocked'), Icons.block, C.orange),
      _Stat('Total Bugs', s.bugs.length, Icons.bug_report, C.pink),
      _Stat('Critical Bugs', s.criticalBugs, Icons.priority_high, C.deepOrange),
      _Stat('Re-tested Bugs', s.retestedCount, Icons.sync, C.teal),
      _Stat('Open Bugs', s.openBugs, Icons.error_outline, C.violet),
    ];

    return ListView(padding: const EdgeInsets.all(20), children: [
      // Header banner
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: C.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: C.primary.withOpacity(.35), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('QA Testing Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('SQA Internship — Day 2 & Day 3', style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 14),
              const Wrap(spacing: 8, runSpacing: 8, children: [
                Pill('app.hisabdo.app', color: Colors.white, icon: Icons.language),
                Pill('Web + Mobile', color: Colors.white, icon: Icons.phone_android),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          Icon(Icons.science, size: 74, color: Colors.white.withOpacity(.25)),
        ]),
      ),
      const SizedBox(height: 20),

      // Summary cards
      GridView.extent(
        maxCrossAxisExtent: 210,
        childAspectRatio: 1.35,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [for (final st in stats) _StatCard(st)],
      ),
      const SizedBox(height: 20),

      // Progress
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(icon: Icons.analytics, title: 'Testing Progress', subtitle: 'Based on test case status'),
          const SizedBox(height: 18),
          _Bar('Executed', executedRatio, C.primary, '$executed / ${s.total} test cases'),
          const SizedBox(height: 14),
          _Bar('Pass rate', passRatio, C.green, '${s.countTc('Passed')} passed of $executed executed'),
          const SizedBox(height: 14),
          const Wrap(spacing: 8, runSpacing: 8, children: [
            Pill('Passed'),
            Pill('Failed'),
            Pill('Blocked'),
            Pill('Not Tested'),
          ]),
        ]),
      ),

      // Day cards
      LayoutBuilder(builder: (context, c) {
        final day2Card = _DayCard(
          title: 'Day 2 Testing',
          subtitle: 'Real application testing',
          icon: Icons.language,
          color: C.blue,
          lines: ['$day2 test cases documented', '${s.bugs.length} bugs reported'],
          tags: const ['Navigation', 'Forms', 'Customers', 'Transactions'],
          button: 'View test cases',
          onTap: () => onNavigate(1),
        );
        final day3Card = _DayCard(
          title: 'Day 3 Deep QA',
          subtitle: 'Boundary, negative & regression',
          icon: Icons.science,
          color: C.pink,
          lines: ['${s.deepDone} / ${s.deep.length} categories completed', '$day3 Day 3 test cases'],
          tags: const ['Boundary', 'Negative', 'Duplicate', 'Regression'],
          button: 'Open Deep QA',
          onTap: () => onNavigate(3),
        );
        if (c.maxWidth > 720) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: day2Card),
            const SizedBox(width: 14),
            Expanded(child: day3Card),
          ]);
        }
        return Column(children: [day2Card, day3Card]);
      }),

      // Quick actions
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(icon: Icons.bolt, title: 'Quick Actions'),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTestCaseScreen())),
              icon: const Icon(Icons.add_task),
              label: const Text('Add Test Case'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: C.pink),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportBugScreen())),
              icon: const Icon(Icons.bug_report),
              label: const Text('Report Bug'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: C.teal),
              onPressed: () => showNoteSheet(context),
              icon: const Icon(Icons.edit_note),
              label: const Text('Add QA Note'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear sample data?'),
                    content: const Text('This removes every test case, bug, retest, note and API entry.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (ok == true) s.clearAll();
              },
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Clear sample data'),
            ),
          ]),
        ]),
      ),
    ]);
  }
}

class _Stat {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  _Stat(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _Stat st;
  const _StatCard(this.st);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [st.color, st.color.withOpacity(.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: st.color.withOpacity(.30), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.22), shape: BoxShape.circle),
          child: Icon(st.icon, color: Colors.white, size: 20),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${st.value}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          Text(st.label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label, caption;
  final double value;
  final Color color;
  const _Bar(this.label, this.value, this.color, this.caption);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('${(value * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(value: value, minHeight: 12, color: color, backgroundColor: color.withOpacity(.12)),
      ),
      const SizedBox(height: 4),
      Text(caption, style: const TextStyle(color: C.muted, fontSize: 12)),
    ]);
  }
}

class _DayCard extends StatelessWidget {
  final String title, subtitle, button;
  final IconData icon;
  final Color color;
  final List<String> lines, tags;
  final VoidCallback onTap;
  const _DayCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lines,
    required this.tags,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accent: color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text(subtitle, style: const TextStyle(color: C.muted, fontSize: 13)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(Icons.check_circle_outline, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(l)),
            ]),
          ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [for (final t in tags) Pill(t, color: color)]),
        const SizedBox(height: 12),
        TextButton.icon(onPressed: onTap, icon: const Icon(Icons.arrow_forward), label: Text(button)),
      ]),
    );
  }
}

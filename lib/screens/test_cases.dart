import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';
import 'add_test_case.dart';

class TestCasesScreen extends StatefulWidget {
  const TestCasesScreen({super.key});

  @override
  State<TestCasesScreen> createState() => _TestCasesScreenState();
}

class _TestCasesScreenState extends State<TestCasesScreen> {
  String q = '', status = 'All', priority = 'All';

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    final list = store.testCases.where((t) {
      final text = '${t.id} ${t.title} ${t.module} ${t.remarks}'.toLowerCase();
      return (q.isEmpty || text.contains(q.toLowerCase())) &&
          (status == 'All' || t.status == status) &&
          (priority == 'All' || t.priority == priority);
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(
            icon: Icons.assignment,
            title: 'Test Cases',
            subtitle: '${list.length} of ${store.testCases.length} shown',
            trailing: FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTestCaseScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: deco('Search by ID, title or module', Icons.search),
          ),
          const SizedBox(height: 10),
          chipRow(['All', ...tcStatuses], status, (v) => setState(() => status = v)),
          chipRow(['All', ...priorities], priority, (v) => setState(() => priority = v)),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const EmptyState(
                icon: Icons.assignment_late,
                title: 'No test cases found',
                message: 'Add a test case or change the search and filters.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: list.length,
                itemBuilder: (_, i) => _TcCard(list[i]),
              ),
      ),
    ]);
  }
}

class _TcCard extends StatelessWidget {
  final TestCase t;
  const _TcCard(this.t);

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    return AppCard(
      accent: colorFor(t.status),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(t.id, color: C.primary, icon: Icons.assignment),
          const SizedBox(width: 8),
          Pill(t.status),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == '_delete') {
                store.deleteTestCase(t);
              } else {
                store.setTcStatus(t, v);
              }
            },
            itemBuilder: (_) => [
              for (final s in tcStatuses) PopupMenuItem(value: s, child: Text('Mark as $s')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: '_delete', child: Text('Delete')),
            ],
          ),
        ]),
        const SizedBox(height: 8),
        Text(t.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.ink)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          Pill(t.module, color: C.teal, icon: Icons.folder_open),
          Pill('${t.priority} priority', color: colorFor(t.priority), icon: Icons.flag),
          Pill(t.day, color: C.violet, icon: Icons.event),
          Pill(fmtDate(t.date), color: C.grey, icon: Icons.calendar_today),
        ]),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 4),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700, color: C.primary)),
            children: [
              kv('Preconditions', t.preconditions),
              kv('Test steps', t.steps),
              kv('Test data', t.data),
              kv('Expected result', t.expected),
              kv('Actual result', t.actual),
              kv('Remarks', t.remarks),
            ],
          ),
        ),
      ]),
    );
  }
}

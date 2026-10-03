import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';
import 'report_bug.dart';

class BugsScreen extends StatefulWidget {
  const BugsScreen({super.key});

  @override
  State<BugsScreen> createState() => _BugsScreenState();
}

class _BugsScreenState extends State<BugsScreen> {
  String q = '', status = 'All', severity = 'All';

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    final list = store.bugs.where((b) {
      final text = '${b.id} ${b.title} ${b.module}'.toLowerCase();
      return (q.isEmpty || text.contains(q.toLowerCase())) &&
          (status == 'All' || b.status == status) &&
          (severity == 'All' || b.severity == severity);
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(
            icon: Icons.bug_report,
            title: 'Bug Tracker',
            subtitle: '${list.length} of ${store.bugs.length} shown',
            trailing: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: C.pink),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportBugScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Report'),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: deco('Search by ID, title or module', Icons.search),
          ),
          const SizedBox(height: 10),
          chipRow(['All', ...bugStatuses], status, (v) => setState(() => status = v)),
          chipRow(['All', ...severities], severity, (v) => setState(() => severity = v)),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const EmptyState(
                icon: Icons.bug_report,
                title: 'No bugs here',
                message: 'Great news - or just report your first bug.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: list.length,
                itemBuilder: (_, i) => _BugCard(list[i]),
              ),
      ),
    ]);
  }
}

class _BugCard extends StatelessWidget {
  final Bug b;
  const _BugCard(this.b);

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    return AppCard(
      accent: colorFor(b.severity),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(b.id, color: C.pink, icon: Icons.bug_report),
          const SizedBox(width: 8),
          Pill(b.severity, icon: Icons.priority_high),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == '_delete') {
                store.deleteBug(b);
              } else {
                store.setBugStatus(b, v);
              }
            },
            itemBuilder: (_) => [
              for (final s in bugStatuses) PopupMenuItem(value: s, child: Text('Set status: $s')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: '_delete', child: Text('Delete')),
            ],
          ),
        ]),
        const SizedBox(height: 8),
        Text(b.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.ink)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: [
          Pill(b.status, icon: Icons.circle),
          Pill(b.module, color: C.teal, icon: Icons.folder_open),
          Pill('${b.priority} priority', color: colorFor(b.priority), icon: Icons.flag),
          Pill(fmtDate(b.date), color: C.grey, icon: Icons.calendar_today),
        ]),
        if (b.evidence.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.attach_file, size: 16, color: C.muted),
            const SizedBox(width: 6),
            Expanded(child: Text(b.evidence, style: const TextStyle(color: C.muted, fontSize: 13))),
          ]),
        ],
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 4),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700, color: C.primary)),
            children: [
              kv('Steps to reproduce', b.steps),
              kv('Expected result', b.expected),
              kv('Actual result', b.actual),
              kv('Remarks', b.remarks),
            ],
          ),
        ),
      ]),
    );
  }
}

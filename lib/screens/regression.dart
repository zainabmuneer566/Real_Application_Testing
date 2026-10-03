import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';

class RegressionScreen extends StatelessWidget {
  const RegressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: SectionHeader(
          icon: Icons.sync,
          title: 'Regression Testing',
          subtitle: '${store.retestedCount} of ${store.retests.length} re-tests completed',
          trailing: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: C.violet),
            onPressed: () => showRetestSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
      ),
      Expanded(
        child: store.retests.isEmpty
            ? const EmptyState(
                icon: Icons.sync_problem,
                title: 'Nothing to re-test yet',
                message: 'Add a bug or test case to re-test after it has been fixed.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: store.retests.length,
                itemBuilder: (_, i) => _RetestCard(store.retests[i]),
              ),
      ),
    ]);
  }
}

class _RetestCard extends StatelessWidget {
  final RetestEntry r;
  const _RetestCard(this.r);

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    final isBug = r.refId.toUpperCase().startsWith('BUG');
    return AppCard(
      accent: colorFor(r.result),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(r.refId, color: isBug ? C.pink : C.primary, icon: isBug ? Icons.bug_report : Icons.assignment),
          const Spacer(),
          IconButton(
            tooltip: 'Delete',
            onPressed: () => store.deleteRetest(r),
            icon: const Icon(Icons.delete_outline),
          ),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          const Text('Original:', style: TextStyle(color: C.muted)),
          Pill(r.originalStatus),
          const Icon(Icons.arrow_forward, size: 16, color: C.muted),
          const Text('Retest:', style: TextStyle(color: C.muted)),
          Pill(r.retestStatus),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          Pill('Result: ${r.result}', color: colorFor(r.result), icon: Icons.fact_check),
          Pill(fmtDate(r.date), color: C.grey, icon: Icons.calendar_today),
        ]),
        if (r.remarks.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(r.remarks, style: const TextStyle(color: C.ink)),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => showRetestSheet(context, existing: r),
          icon: const Icon(Icons.edit),
          label: const Text('Update retest result'),
        ),
      ]),
    );
  }
}

Future<void> showRetestSheet(BuildContext context, {RetestEntry? existing}) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _RetestSheet(existing: existing),
    );

class _RetestSheet extends StatefulWidget {
  final RetestEntry? existing;
  const _RetestSheet({this.existing});

  @override
  State<_RetestSheet> createState() => _RetestSheetState();
}

class _RetestSheetState extends State<_RetestSheet> {
  final _form = GlobalKey<FormState>();
  late String? ref = widget.existing?.refId;
  late String retestStatus = widget.existing?.retestStatus ?? 'In Retest';
  late String result = widget.existing?.result ?? 'Pending';
  late DateTime date = widget.existing?.date ?? DateTime.now();
  late final remarks = TextEditingController(text: widget.existing?.remarks ?? '');

  @override
  void dispose() {
    remarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    final editing = widget.existing != null;
    final ids = store.allRefIds;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(
              icon: Icons.sync,
              title: editing ? 'Update Retest' : 'Add Retest',
              subtitle: editing ? widget.existing!.refId : 'Pick a bug or test case',
            ),
            const SizedBox(height: 16),
            if (!editing)
              DropdownButtonFormField<String>(
                value: ref,
                isExpanded: true,
                decoration: deco('Bug / Test Case ID *', Icons.tag),
                items: [for (final i in ids) DropdownMenuItem(value: i, child: Text(i))],
                onChanged: (v) => setState(() => ref = v),
                validator: (v) => v == null ? 'Choose an ID (add a bug or test case first if the list is empty)' : null,
              ),
            if (!editing) const SizedBox(height: 14),
            dd('Retest Status', Icons.timelapse, retestStatus, retestStatuses, (v) => setState(() => retestStatus = v)),
            const SizedBox(height: 14),
            dd('Result', Icons.fact_check, result, retestResults, (v) => setState(() => result = v)),
            const SizedBox(height: 14),
            dateField(context, 'Retest date', date, (d) => setState(() => date = d)),
            const SizedBox(height: 14),
            tf(remarks, 'Remarks', Icons.notes, lines: 2),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  if (editing) {
                    final r = widget.existing!;
                    r.retestStatus = retestStatus;
                    r.result = result;
                    r.date = date;
                    r.remarks = remarks.text.trim();
                    store.touch();
                  } else {
                    store.addRetest(RetestEntry(
                      refId: ref!,
                      originalStatus: store.originalStatusOf(ref!),
                      retestStatus: retestStatus,
                      result: result,
                      date: date,
                      remarks: remarks.text.trim(),
                    ));
                  }
                  showOk(context, 'Retest saved');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

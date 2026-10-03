import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';

const _noteColors = <String, Color>{
  'UI/UX': C.violet,
  'Error Messages': C.red,
  'Responsiveness': C.blue,
  'Navigation': C.teal,
  'Customer Flow': C.pink,
  'Transaction Flow': C.green,
  'General': C.orange,
};

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    final list = store.notes.where((n) => filter == 'All' || n.category == filter).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(
            icon: Icons.sticky_note_2,
            title: 'QA Notes & Findings',
            subtitle: '${store.notes.length} observations',
            trailing: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: C.teal),
              onPressed: () => showNoteSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ),
          const SizedBox(height: 12),
          chipRow(['All', ...noteCategories.keys], filter, (v) => setState(() => filter = v)),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const EmptyState(
                icon: Icons.edit_note,
                title: 'No notes yet',
                message: 'Record UI/UX, error message and flow observations here.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final n = list[i];
                  final color = _noteColors[n.category] ?? C.grey;
                  return AppCard(
                    accent: color,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
                        child: Icon(noteCategories[n.category] ?? Icons.note, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(n.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Wrap(spacing: 6, children: [
                            Pill(n.category, color: color),
                            Pill(fmtDate(n.date), color: C.grey, icon: Icons.calendar_today),
                          ]),
                          const SizedBox(height: 8),
                          SelectableText(n.body, style: const TextStyle(height: 1.35)),
                        ]),
                      ),
                      IconButton(onPressed: () => store.deleteNote(n), icon: const Icon(Icons.delete_outline)),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }
}

Future<void> showNoteSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _NoteSheet(),
    );

class _NoteSheet extends StatefulWidget {
  const _NoteSheet();

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  final _form = GlobalKey<FormState>();
  final title = TextEditingController();
  final body = TextEditingController();
  String category = 'UI/UX';

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SectionHeader(icon: Icons.edit_note, title: 'Add QA Note', subtitle: 'Record an observation'),
            const SizedBox(height: 16),
            dd('Category', Icons.category, category, noteCategories.keys.toList(), (v) => setState(() => category = v)),
            const SizedBox(height: 14),
            tf(title, 'Title', Icons.title, required: true),
            const SizedBox(height: 14),
            tf(body, 'Observation', Icons.notes, required: true, lines: 4),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  store.addNote(QaNote(category: category, title: title.text.trim(), body: body.text.trim()));
                  showOk(context, 'Note saved');
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Note'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

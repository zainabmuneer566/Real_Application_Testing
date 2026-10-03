import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';

class DeepQaScreen extends StatelessWidget {
  const DeepQaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = QaScope.of(context);
    final ratio = s.deep.isEmpty ? 0.0 : s.deepDone / s.deep.length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(
            icon: Icons.science,
            title: 'Day 3 — Deep QA',
            subtitle: '${s.deepDone} of ${s.deep.length} categories completed',
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 12,
              color: C.pink,
              backgroundColor: C.pink.withOpacity(.12),
            ),
          ),
        ]),
      ),
      LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth > 760 ? 2 : 1;
        final w = (c.maxWidth - 14 * (cols - 1)) / cols;
        return Wrap(
          spacing: 14,
          children: [for (final cat in s.deep) SizedBox(width: w, child: _CategoryCard(cat))],
        );
      }),
    ]);
  }
}

class _CategoryCard extends StatefulWidget {
  final DeepCategory cat;
  const _CategoryCard(this.cat);

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  late final TextEditingController notes = TextEditingController(text: widget.cat.notes);

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final store = QaScope.of(context);
    return AppCard(
      accent: cat.color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cat.color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(cat.icon, color: cat.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(cat.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          Pill(cat.status),
        ]),
        const SizedBox(height: 10),
        Text(cat.description, style: const TextStyle(color: C.muted)),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final i in cat.items) Pill(i, color: cat.color, icon: Icons.check),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: dd('Status', Icons.timelapse, cat.status, deepStatuses, (v) {
              cat.status = v;
              store.touch();
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: dd('Result', Icons.rule, cat.result, deepResults, (v) {
              cat.result = v;
              store.touch();
            }),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: notes,
          minLines: 2,
          maxLines: 5,
          onChanged: (v) => cat.notes = v,
          decoration: deco('Notes', Icons.edit_note, hint: 'What did you try? What happened?'),
        ),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: Pill('Result: ${cat.result}', color: colorFor(cat.result))),
      ]),
    );
  }
}

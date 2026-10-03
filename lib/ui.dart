import 'package:flutter/material.dart';

/// App colors ---------------------------------------------------------------
class C {
  static const primary = Color(0xFF5B5BD6);
  static const violet = Color(0xFF8E54E9);
  static const bg = Color(0xFFF4F6FB);
  static const ink = Color(0xFF1E293B);
  static const muted = Color(0xFF64748B);
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFDC2626);
  static const orange = Color(0xFFF59E0B);
  static const deepOrange = Color(0xFFEA580C);
  static const blue = Color(0xFF2563EB);
  static const grey = Color(0xFF94A3B8);
  static const teal = Color(0xFF0D9488);
  static const pink = Color(0xFFDB2777);
  static const gradient = LinearGradient(
    colors: [primary, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// One place that decides the color of every status / severity / priority.
final Map<String, Color> _colors = {
  // test case status
  'Passed': C.green, 'Failed': C.red, 'Blocked': C.orange, 'Not Tested': C.grey,
  // severity / priority
  'Critical': C.red, 'High': C.deepOrange, 'Medium': C.orange, 'Low': C.blue,
  // bug status
  'Open': C.red, 'In Progress': C.blue, 'Fixed': C.teal, 'Retest': C.violet,
  'Closed': C.green, 'Reopened': C.deepOrange,
  // regression
  'Still Reproducible': C.red, 'Not Reproducible': C.green, 'Pending': C.grey,
  'In Retest': C.blue, 'Completed': C.green,
  // deep QA + api
  'Not Started': C.grey, 'Pass': C.green, 'Fail': C.red, 'Partial': C.orange,
};

Color colorFor(String v) => _colors[v] ?? C.grey;

Color methodColor(String m) {
  switch (m) {
    case 'GET':
      return C.green;
    case 'POST':
      return C.blue;
    case 'PUT':
      return C.orange;
    case 'PATCH':
      return C.violet;
    case 'DELETE':
      return C.red;
    default:
      return C.grey;
  }
}

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
    scaffoldBackgroundColor: C.bg,
    fontFamily: 'Roboto',
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

/// Reusable widgets -----------------------------------------------------------

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final EdgeInsets padding;
  const AppCard({super.key, required this.child, this.accent, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: Colors.white,
          child: accent == null
              ? body
              : IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Container(width: 6, color: accent),
                    Expanded(child: body),
                  ]),
                ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  const Pill(this.label, {super.key, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? colorFor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withOpacity(.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: c), const SizedBox(width: 4)],
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ]),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader({super.key, required this.icon, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(gradient: C.gradient, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: C.ink)),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(color: C.muted, fontSize: 13)),
        ]),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(color: C.primary.withOpacity(.08), shape: BoxShape.circle),
            child: Icon(icon, size: 52, color: C.primary),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: C.muted)),
        ]),
      ),
    );
  }
}

/// Label + value row used inside expanded cards.
Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted, letterSpacing: .6)),
        const SizedBox(height: 2),
        SelectableText(v.trim().isEmpty ? '—' : v, style: const TextStyle(color: C.ink, height: 1.35)),
      ]),
    );

Widget monoBlock(String text) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      child: SelectableText(text.trim().isEmpty ? '—' : text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: C.ink)),
    );

/// Horizontal filter chips.
Widget chipRow(List<String> options, String selected, ValueChanged<String> onSelect) => SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(o),
                selected: o == selected,
                selectedColor: C.primary.withOpacity(.18),
                onSelected: (_) => onSelect(o),
              ),
            ),
        ],
      ),
    );

/// Form helpers ---------------------------------------------------------------

InputDecoration deco(String label, IconData icon, {String? hint}) {
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, size: 20, color: C.primary),
    filled: true,
    fillColor: Colors.white,
    border: b(const Color(0xFFE2E8F0)),
    enabledBorder: b(const Color(0xFFE2E8F0)),
    focusedBorder: b(C.primary, 2),
    errorBorder: b(C.red),
    focusedErrorBorder: b(C.red, 2),
  );
}

String? _req(String label, String? v) =>
    (v == null || v.trim().isEmpty) ? '$label cannot be empty' : null;

Widget tf(TextEditingController c, String label, IconData icon,
    {bool required = false, int lines = 1, String? hint, String? Function(String?)? validator}) {
  String? Function(String?)? val = validator;
  if (val == null && required) val = (v) => _req(label, v);
  return TextFormField(
    controller: c,
    minLines: lines,
    maxLines: lines == 1 ? 1 : lines + 4,
    decoration: deco(required ? '$label *' : label, icon, hint: hint),
    validator: val,
  );
}

Widget dd(String label, IconData icon, String value, List<String> items, ValueChanged<String> onChanged) =>
    DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      isExpanded: true,
      decoration: deco(label, icon),
      items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );

Widget dateField(BuildContext context, String label, DateTime value, ValueChanged<DateTime> onPick) => InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2024),
          lastDate: DateTime(2035),
        );
        if (d != null) onPick(d);
      },
      child: InputDecorator(decoration: deco(label, Icons.event), child: Text(fmtDate(value))),
    );

void showOk(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? C.red : C.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(children: [
        Icon(error ? Icons.error : Icons.check_circle, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700))),
      ]),
    ));
}

Future<void> showSuccessDialog(BuildContext context, String title, String message) => showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: C.green.withOpacity(.12), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: C.green, size: 52),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: C.muted)),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [Builder(builder: (ctx) => FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')))],
      ),
    );

/// Full-screen form scaffold used by every "Add ..." screen.
class FormShell extends StatelessWidget {
  final String title, subtitle, saveLabel;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onSave;
  const FormShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.formKey,
    required this.children,
    required this.onSave,
    this.saveLabel = 'Save',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: C.gradient)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Form(
            key: formKey,
            child: ListView(padding: const EdgeInsets.all(20), children: [
              AppCard(child: SectionHeader(icon: icon, title: title, subtitle: subtitle)),
              for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 14), child: c),
              const SizedBox(height: 6),
              FilledButton.icon(onPressed: onSave, icon: const Icon(Icons.save), label: Text(saveLabel)),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

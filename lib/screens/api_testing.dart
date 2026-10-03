import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../ui.dart';

class ApiScreen extends StatelessWidget {
  const ApiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    return ListView(padding: const EdgeInsets.all(20), children: [
      SectionHeader(
        icon: Icons.api,
        title: 'API Testing (Postman)',
        subtitle: 'Optional — ${store.apiTests.length} requests documented',
        trailing: FilledButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddApiScreen())),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.orange.withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.orange.withOpacity(.5)),
        ),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.warning_amber_rounded, color: C.deepOrange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Test safely: only call APIs you are allowed to test, use your own test account and dummy data, '
              'avoid destructive requests (DELETE / bulk updates) on real records, and never paste real '
              'passwords or tokens here — write "Bearer <hidden>" instead.',
              style: TextStyle(height: 1.4),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      if (store.apiTests.isEmpty)
        const SizedBox(
          height: 320,
          child: EmptyState(
            icon: Icons.cloud_off,
            title: 'No API tests yet',
            message: 'Document your Postman requests, responses and results here.',
          ),
        )
      else
        for (final a in store.apiTests) _ApiCard(a),
    ]);
  }
}

class _ApiCard extends StatelessWidget {
  final ApiTest a;
  const _ApiCard(this.a);

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    final code = int.tryParse(a.statusCode) ?? 0;
    final codeColor = code >= 500 ? C.red : code >= 400 ? C.orange : code >= 200 ? C.green : C.grey;
    return AppCard(
      accent: methodColor(a.method),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(a.method, color: methodColor(a.method)),
          const SizedBox(width: 8),
          if (a.statusCode.isNotEmpty) Pill(a.statusCode, color: codeColor, icon: Icons.http),
          const SizedBox(width: 8),
          Pill(a.result, color: colorFor(a.result == 'Not Tested' ? 'Pending' : a.result)),
          const Spacer(),
          IconButton(onPressed: () => store.deleteApi(a), icon: const Icon(Icons.delete_outline)),
        ]),
        const SizedBox(height: 8),
        Text(a.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        SelectableText(a.endpoint, style: const TextStyle(fontFamily: 'monospace', color: C.blue, fontSize: 13)),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700, color: C.primary)),
            children: [
              kv('Authentication', a.auth),
              const Text('REQUEST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted)),
              const SizedBox(height: 4),
              monoBlock(a.request),
              const SizedBox(height: 10),
              const Text('RESPONSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted)),
              const SizedBox(height: 4),
              monoBlock(a.response),
              const SizedBox(height: 10),
              kv('Notes', a.notes),
            ],
          ),
        ),
      ]),
    );
  }
}

class AddApiScreen extends StatefulWidget {
  const AddApiScreen({super.key});

  @override
  State<AddApiScreen> createState() => _AddApiScreenState();
}

class _AddApiScreenState extends State<AddApiScreen> {
  final _form = GlobalKey<FormState>();
  final name = TextEditingController();
  final endpoint = TextEditingController();
  final request = TextEditingController();
  final response = TextEditingController();
  final code = TextEditingController();
  final auth = TextEditingController(text: 'None');
  final notes = TextEditingController();
  String method = 'GET', result = 'Not Tested';

  @override
  void dispose() {
    for (final c in [name, endpoint, request, response, code, auth, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = QaScope.of(context);
    return FormShell(
      title: 'Add API Test',
      subtitle: 'Document one Postman request',
      icon: Icons.api,
      formKey: _form,
      saveLabel: 'Save API Test',
      onSave: () {
        if (!_form.currentState!.validate()) {
          showOk(context, 'Please fix the highlighted fields', error: true);
          return;
        }
        store.addApi(ApiTest(
          name: name.text.trim(),
          endpoint: endpoint.text.trim(),
          method: method,
          request: request.text.trim(),
          response: response.text.trim(),
          statusCode: code.text.trim(),
          auth: auth.text.trim(),
          result: result,
          notes: notes.text.trim(),
        ));
        showOk(context, 'API test added successfully');
        Navigator.pop(context);
      },
      children: [
        tf(name, 'API Name', Icons.label, required: true),
        tf(endpoint, 'Endpoint', Icons.link, required: true, hint: 'https://...'),
        dd('HTTP Method', Icons.swap_horiz, method, httpMethods, (v) => setState(() => method = v)),
        tf(request, 'Request (headers / body)', Icons.upload, lines: 4, hint: 'Hide tokens: Bearer <hidden>'),
        tf(response, 'Response', Icons.download, lines: 4),
        tf(code, 'Status Code', Icons.numbers, hint: '200', validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final n = int.tryParse(v.trim());
          return (n == null || n < 100 || n > 599) ? 'Enter a valid HTTP status code (100-599)' : null;
        }),
        tf(auth, 'Authentication', Icons.lock, hint: 'None / Bearer / API key'),
        dd('Result', Icons.fact_check, result, apiResults, (v) => setState(() => result = v)),
        tf(notes, 'Notes', Icons.notes, lines: 2),
      ],
    );
  }
}

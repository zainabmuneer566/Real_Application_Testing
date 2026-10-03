import 'package:flutter/material.dart';

const tcStatuses = ['Passed', 'Failed', 'Blocked', 'Not Tested'];
const priorities = ['High', 'Medium', 'Low'];
const severities = ['Critical', 'High', 'Medium', 'Low'];
const bugStatuses = ['Open', 'In Progress', 'Fixed', 'Retest', 'Closed', 'Reopened'];
const retestStatuses = ['Pending', 'In Retest', 'Completed'];
const retestResults = ['Pending', 'Passed', 'Failed', 'Still Reproducible', 'Fixed', 'Not Reproducible'];
const deepStatuses = ['Not Started', 'In Progress', 'Completed'];
const deepResults = ['Pending', 'Pass', 'Fail', 'Partial'];
const httpMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
const apiResults = ['Not Tested', 'Pass', 'Fail', 'Blocked'];
const days = ['Day 2', 'Day 3'];
const modules = [
  'Authentication',
  'Navigation',
  'Customers',
  'Transactions',
  'Forms',
  'UI/UX',
  'Responsive',
  'API',
  'Other',
];

const noteCategories = <String, IconData>{
  'UI/UX': Icons.palette,
  'Error Messages': Icons.error_outline,
  'Responsiveness': Icons.devices,
  'Navigation': Icons.alt_route,
  'Customer Flow': Icons.person,
  'Transaction Flow': Icons.payments,
  'General': Icons.sticky_note_2,
};

class TestCase {
  String id, title, module, preconditions, steps, data, expected, actual, status, priority, remarks, day;
  DateTime date;
  TestCase({
    required this.id,
    required this.title,
    required this.module,
    this.preconditions = '',
    this.steps = '',
    this.data = '',
    required this.expected,
    this.actual = '',
    this.status = 'Not Tested',
    this.priority = 'Medium',
    this.remarks = '',
    this.day = 'Day 2',
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

class Bug {
  String id, title, module, steps, expected, actual, severity, priority, status, evidence, remarks;
  DateTime date;
  Bug({
    required this.id,
    required this.title,
    required this.module,
    required this.steps,
    required this.expected,
    required this.actual,
    this.severity = 'Medium',
    this.priority = 'Medium',
    this.status = 'Open',
    this.evidence = '',
    this.remarks = '',
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

class RetestEntry {
  String refId, originalStatus, retestStatus, result, remarks;
  DateTime date;
  RetestEntry({
    required this.refId,
    required this.originalStatus,
    this.retestStatus = 'Pending',
    this.result = 'Pending',
    this.remarks = '',
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

class QaNote {
  String category, title, body;
  DateTime date;
  QaNote({required this.category, required this.title, required this.body, DateTime? date})
      : date = date ?? DateTime.now();
}

class ApiTest {
  String name, endpoint, method, request, response, statusCode, auth, result, notes;
  ApiTest({
    required this.name,
    required this.endpoint,
    this.method = 'GET',
    this.request = '',
    this.response = '',
    this.statusCode = '',
    this.auth = 'None',
    this.result = 'Not Tested',
    this.notes = '',
  });
}

class DeepCategory {
  final String title, description;
  final IconData icon;
  final Color color;
  final List<String> items;
  String status, result, notes;
  DeepCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
    this.status = 'Not Started',
    this.result = 'Pending',
    this.notes = '',
  });
}

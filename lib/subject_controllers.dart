import 'package:flutter/material.dart';

class SubjectControllers {
  final TextEditingController exam;
  final TextEditingController td;

  SubjectControllers()
    : exam = TextEditingController(text: ''),
      td = TextEditingController(text: '');

  void dispose() {
    exam.dispose();
    td.dispose();
  }

  void clear() {
    exam.text = '';
    td.text = '';
  }
}

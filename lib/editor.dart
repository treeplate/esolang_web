import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ast.dart';
import 'errors.dart';
import 'parser.dart';

class Editor extends StatefulWidget {
  @Preview()
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    List<ParseError> parseErrors = [];
    Program program;
    try {
      program = parseProgram(controller.text, parseErrors);
    } on UnexpectedEOFException {
      program = Program(program: []);
    }
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              style: GoogleFonts.courierPrime(),
              maxLines: null,
              onChanged: (value) {
                setState(() {});
              },
            ),
            Text('AST'),
            ...program.program.map((e) => Text(e.toString())),
            Text('ERRORS'),
            ...parseErrors.map((e) => Text(e.toString())),
          ],
        ),
      ),
    );
  }
}

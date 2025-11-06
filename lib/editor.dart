import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:texteditor/lexer.dart';

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
    return SizedBox(
      width: 200,
      height: 400,
      child: ListView(
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
          ...tokenise(controller.text).map((e) => Text(e.toString())),
        ],
      ),
    );
  }
}
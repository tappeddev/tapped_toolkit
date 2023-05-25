import 'package:flutter/material.dart';
import 'package:tapped_toolkit/tapped_toolkit.dart';

class BaseTextFieldExample extends StatefulWidget {
  const BaseTextFieldExample({Key? key}) : super(key: key);

  @override
  State<BaseTextFieldExample> createState() => _BaseTextFieldExampleState();
}

class _BaseTextFieldExampleState extends State<BaseTextFieldExample> {
  var _text = "";

  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      text: _text,
      onChanged: (value) {
        setState(() => _text = value);
      },
      decoration: const InputDecoration(label: Text("Enter some text")),
      textStyle: const TextStyle(),
    );
  }
}

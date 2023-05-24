import 'package:flutter/material.dart';
import 'package:tapped_toolkit/tapped_toolkit.dart';

class BaseTextFieldExample extends StatefulWidget {
  const BaseTextFieldExample({Key? key}) : super(key: key);

  @override
  State<BaseTextFieldExample> createState() => _BaseTextFieldExampleState();
}

class _BaseTextFieldExampleState extends State<BaseTextFieldExample> {
  @override
  Widget build(BuildContext context) {
    return BaseTextField(
      text: "0000",
      onChanged: (value) {},
      decoration: const InputDecoration(label: Text("Enter some text")),
      textStyle: const TextStyle(),
    );
  }
}

import 'package:base_text_field/base_text_field.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  final String initialTextFieldText;

  const TestScreen({
    Key? key,
    this.initialTextFieldText = "",
  }) : super(key: key);

  @override
  State<TestScreen> createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {
  final textFieldKey = GlobalKey<BaseTextFieldState>();
  late var text = widget.initialTextFieldText;

  void updateText(String newText) {
    setState(() => text = newText);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: BaseTextField(
              key: textFieldKey,
              text: text,
              onChanged: (newText) {
                setState(() => text = newText);
              },
              decoration: InputDecoration(),
              textStyle: Theme.of(context).textTheme.bodySmall!,
            ),
          ),
        );
      }),
    );
  }
}

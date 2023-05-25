import 'package:example/base_text_field_example/base_text_field_example.dart';
import 'package:example/custom_drop_down_example/custom_drop_down_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(),
            body: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: const [
                  BaseTextFieldExample(),
                  SizedBox(height: 25),
                  DropDownExample(
                    numberOfEntries: 25,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

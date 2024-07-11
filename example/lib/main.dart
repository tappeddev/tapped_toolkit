import 'package:example/custom_drop_down_example/custom_drop_down_example.dart';
import 'package:flutter/material.dart';
import 'package:tapped_toolkit/tapped_toolkit.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  var _text = "";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(),
            body: Container(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BaseTextField(
                      text: _text,
                      onChanged: (value) {
                        setState(() => _text = value);
                      },
                      decoration: const InputDecoration(label: Text("Enter some text")),
                      textStyle: const TextStyle(),
                      validator: (input) {
                        if (input == null || input.isEmpty) {
                          return "Enter something";
                        }
                        if (input.length < 6) {
                          return "Input is too short";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _formKey.currentState?.validate();
                      },
                      child: const Text("Validate textfield"),
                    ),
                    const SizedBox(height: 25),
                    MaterialButton(
                      onPressed: () {
                        setState(() => _text = "This is a really long text...");
                      },
                      child: const Text("Add large text"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() => _text = "Short text.");
                      },
                      child: const Text("Add small text"),
                    ),
                    const DropDownExample(numberOfEntries: 25),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

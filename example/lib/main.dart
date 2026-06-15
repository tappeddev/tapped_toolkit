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
      home: Form(
        key: _formKey,
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(),
              body: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BaseTextField(
                      text: _text,
                      validator: (value) {
                        if ((value?.length ?? 0) < 2) return "Enter text";

                        return null;
                      },
                      onChanged: (value) {
                        setState(() => _text = value);
                      },
                      decoration:
                          const InputDecoration(hintText: "Enter some text"),
                      textStyle: const TextStyle(),
                    ),
                    const SizedBox(height: 25),
                    MaterialButton(
                      onPressed: () {
                        _formKey.currentState!.validate();
                      },
                      child: const Text("Validate"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() => _text = "This is a really long text...");
                      },
                      child: const Text("Add large text"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() => _text = "");
                      },
                      child: const Text("Remove text"),
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
            );
          },
        ),
      ),
    );
  }
}

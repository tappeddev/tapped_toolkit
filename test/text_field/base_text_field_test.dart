import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapped_toolkit/src/text_field/base_text_field.dart';

void main() {
  testWidgets("sets and updates the text correctly", (tester) async {
    final screenKey = GlobalKey<_ScreenState>();
    _ScreenState screenState() => screenKey.currentState!;
    BaseTextFieldState textFieldState() =>
        screenState().textFieldKey.currentState!;

    // Add the TextField with and initial message and make sure
    // that the internal TextEditingController has that value.
    await tester.pumpWidget(
      _TestScreen(key: screenKey, initialTextFieldText: "initial"),
    );
    expect(textFieldState().textEditingController.text, "initial");

    // Update the text property in the state and make sure the
    // BaseTextField applies this onto the TextEditingController.
    screenState().updateText("Updated1");
    await tester.pumpAndSettle();
    expect(textFieldState().textEditingController.text, "Updated1");

    // Enter text manually in the BaseTextField and check if the text
    // is set in the screen via the onChange and also in the
    // TextEditingController.
    final textFieldFinder = find.byKey(screenKey.currentState!.textFieldKey);
    await tester.enterText(textFieldFinder, "Update2");
    await tester.pumpAndSettle();
    expect(screenState().text, "Update2");
    expect(textFieldState().textEditingController.text, "Update2");
  });
}

class _TestScreen extends StatefulWidget {
  final String initialTextFieldText;

  const _TestScreen({
    Key? key,
    this.initialTextFieldText = "",
  }) : super(key: key);

  @override
  State<_TestScreen> createState() => _ScreenState();
}

class _ScreenState extends State<_TestScreen> {
  final textFieldKey = GlobalKey<BaseTextFieldState>();
  late var text = widget.initialTextFieldText;

  void updateText(String newText) {
    setState(() => text = newText);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: BaseTextField(
                key: textFieldKey,
                text: text,
                onChanged: (newText, source) {
                  setState(() => text = newText);
                },
                decoration: const InputDecoration(),
                textStyle: Theme.of(context).textTheme.bodySmall!,
              ),
            ),
          );
        },
      ),
    );
  }
}

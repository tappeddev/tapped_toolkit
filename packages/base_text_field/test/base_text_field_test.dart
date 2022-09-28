import 'package:base_text_field/src/base_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/test_screen.dart';

void main() {
  testWidgets("sets and updates the text correctly", (tester) async {
    final screenKey = GlobalKey<TestScreenState>();
    TestScreenState screenState() => screenKey.currentState!;
    BaseTextFieldState textFieldState() =>
        screenState().textFieldKey.currentState!;

    // Add the TextField with and initial message and make sure
    // that the internal TextEditingController has that value.
    await tester.pumpWidget(
      TestScreen(key: screenKey, initialTextFieldText: "initial"),
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
    var textFieldFinder = find.byKey(screenKey.currentState!.textFieldKey);
    await tester.enterText(textFieldFinder, "Update2");
    await tester.pumpAndSettle();
    expect(screenState().text, "Update2");
    expect(textFieldState().textEditingController.text, "Update2");
  });
}

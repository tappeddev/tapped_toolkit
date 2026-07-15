import 'package:flutter/widgets.dart';

/// ⚠️⚠️⚠️⚠️⚠️⚠️
/// A copy of the package: [https://pub.dev/packages/flutter_keyboard_visibility]
/// Because of two reasons:
/// - https://github.com/MisterJimson/flutter_keyboard_visibility/issues/150 is not merged and we have a warning when building web:
///   Error in pipeline, when building web:  Found incompatibilities with WebAssembly. package:flutter_keyboard_visibility_web/flutter_keyboard_visibility_web.dart 1:1 - dart:html unsupported (0)
/// - The package is huge and we only need one specific file, which is [KeyboardDismissOnTap]
/// - The support of the package is terrible
///
/// We basically copied one file and cleaned it up.
/// ⚠️⚠️⚠️⚠️⚠️⚠️

/// Removes the current focus and hides the keyboard when
/// the user taps on this widget.
///
/// Place this widget somewhere near the top of your widget
/// tree and when the user taps outside of a focused widget,
/// the focus will be removed and the keyboard will be hidden.
class KeyboardDismissOnTap extends StatelessWidget {
  const KeyboardDismissOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

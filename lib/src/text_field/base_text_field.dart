import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tapped_toolkit/src/after_first_build/after_first_build_mixin.dart';
import 'package:tapped_toolkit/src/after_first_build/on_next_frame_extension.dart';
import 'package:universal_platform/universal_platform.dart';

enum TextFieldSource { inside, outside }

typedef TextStyleMutation = TextStyle Function(TextStyle style);

class BaseTextField extends StatefulWidget {
  final String text;

  final void Function(String value, TextFieldSource source) onChanged;
  final void Function(String value)? onFieldSubmitted;
  final String? Function(String? value)? validator;
  final TextStyle Function(TextStyle)? textStyleMutator;
  final TextStyle textStyle;
  final bool autoValidate;
  final bool autofocus;

  final int? minLines;
  final int? maxLines;
  final int? maxLength;

  final TextInputType? textInputType;

  final InputDecoration decoration;

  /// [AutofillHints]
  /// e.g. [AutofillHints.email]
  final Iterable<String>? autofillHints;

  final ValueChanged<bool>? onFocusChanged;

  final FocusNode? focusNode;

  final bool expands;

  /// Returns if the TextField is valid or contains an error
  final ValueChanged<bool>? onValidationChanged;

  final TextInputAction? textInputAction;

  final VoidCallback? onLeave;

  final List<TextInputFormatter>? inputFormatter;

  /// https://stackoverflow.com/questions/63690311/flutter-textfield-difference-between-onedittingcomplete-and-onsubmionsubmittedtted
  /// Called when the user tap the "continue" button on the keyboard
  /// When there is no method provided (or the method/callback is null), the keyboard will be closed
  final VoidCallback? onEditingComplete;

  final bool obscureText;

  final bool autocorrect;

  final bool enableSuggestions;

  /// Defines the state of the keyboard (uppercase or lowercase) when selecting the TextField
  final TextCapitalization textCapitalization;

  final TextAlignVertical textAlignVertical;
  final bool? cursorOpacityAnimates;

  final bool readOnly;

  final VoidCallback? onTap;

  const BaseTextField({
    required this.text,
    required this.onChanged,
    required this.decoration,
    required this.textStyle,
    this.onFieldSubmitted,
    this.onValidationChanged,
    this.textInputType,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.expands = false,
    this.validator,
    this.textStyleMutator,
    this.maxLength,
    this.autoValidate = false,
    this.autofocus = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.onFocusChanged,
    this.textInputAction,
    this.autofillHints,
    this.onLeave,
    this.onEditingComplete,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatter,
    this.textAlignVertical = TextAlignVertical.center,
    this.readOnly = false,
    this.cursorOpacityAnimates,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  BaseTextFieldState createState() => BaseTextFieldState();
}

class BaseTextFieldState extends State<BaseTextField>
    with AfterFirstBuildMixin {
  late final _focusNode = widget.focusNode ?? FocusNode();

  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  late TextEditingController _textEditingController;

  @visibleForTesting
  TextEditingController get textEditingController => _textEditingController;

  final _selectableRegionFocusNode = FocusNode();

  @visibleForTesting
  FocusNode get focusNode => _focusNode;

  // We previous used the onChange event from the [TextFormField], since adding a listener to the [TextEditingController] is also called
  // when we focus / unfocus the [TextFormField].
  // 💾 This was the previous documentation:
  // 💾 use onChange instead of [TextEditingController.addListener]
  // 💾 because this will notify a text change when we loose focus
  // 💾 when routing back. This will trigger a new search which is wrong.
  // Since we now use the listener, we need to distinct the value by ourself.
  late String _previousTextValue;

  bool _textFieldIsValid = true;

  @override
  void initState() {
    super.initState();

    // We need to do it like that, otherwise we initialize is to late
    // and the initial value is not correct.
    _previousTextValue = widget.text;

    // We need to avoid to add a empty text into the constructor since the [_textEditingController.addListener] callback is triggered on an empty string
    if (widget.text.replaceAll(" ", "").isNotEmpty) {
      final text = widget.text;

      _textEditingController = TextEditingController(text: text);

      // We always want the cursor at the end of the text in the initial state
      onNextFrame(() {
        // FROM: https://stackoverflow.com/questions/56851701/how-to-set-cursor-position-at-the-end-of-the-value-in-flutter-in-textfield
        final selection = TextSelection.collapsed(offset: text.length);

        _textEditingController.value = _textEditingController.value
            .copyWith(text: text, selection: selection);
      });
    } else {
      _textEditingController = TextEditingController();
    }

    _textEditingController
        .addListener(() => _onChanged(_textEditingController.text));

    if (UniversalPlatform.isWeb) {
      _selectableRegionFocusNode.addListener(() {
        if (_selectableRegionFocusNode.hasPrimaryFocus) {
          _focusNode.requestFocus();
        }
      });
    }

    _focusNode.addListener(_addFocusNodeListener);
  }

  @override
  FutureOr<void> afterFirstBuild() {
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.textStyle;

    final textField = TextFormField(
      key: _formFieldKey,
      textAlignVertical: widget.textAlignVertical,
      readOnly: widget.readOnly || widget.onTap != null,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatter,
      onFieldSubmitted: widget.onFieldSubmitted,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      expands: widget.expands,
      onTap: widget.onTap,
      maxLengthEnforcement:
          widget.maxLength != null ? MaxLengthEnforcement.enforced : null,
      validator: (value) {
        final validationValue = widget.validator?.call(value);

        final isTextFieldValid = validationValue == null;
        if (widget.onValidationChanged != null &&
            isTextFieldValid != _textFieldIsValid) {
          onNextFrame(() => widget.onValidationChanged!(isTextFieldValid));
        }

        _textFieldIsValid = validationValue == null;
        return validationValue;
      },
      autovalidateMode: widget.autoValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      keyboardType: widget.textInputType,
      style: widget.textStyleMutator != null
          ? widget.textStyleMutator!(style)
          : style,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      focusNode: _focusNode,
      controller: _textEditingController,
      decoration: widget.decoration,
    );

    if (UniversalPlatform.isWeb) {
      // ⚠️ We added the [SelectionArea], since we had an issue with the text filed in the web ->  https://github.com/flutter/flutter/issues/158095
      return SelectableRegion(
        focusNode: _selectableRegionFocusNode,
        selectionControls: emptyTextSelectionControls,
        child: textField,
      );
    }

    return textField;
  }

  @override
  void didUpdateWidget(covariant BaseTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final text = widget.text;

    if (oldWidget.text != text) {
      // We don't need anything whenever the change is from the textfield itself
      if (_textEditingController.text == text) return;

      // this will be called, whenever a change comes from outside and we need to handle the changed event
      onNextFrame(() {
        if (text.isEmpty) {
          _textEditingController.clear();
        } else {
          final selection = _textEditingController.selection;

          final isNewTextSmaller = oldWidget.text.length > text.length;
          _textEditingController.value = _textEditingController.value.copyWith(
            text: text,
            selection: isNewTextSmaller
                ? TextSelection.collapsed(offset: text.length)
                : selection.copyWith(
                    baseOffset: text.length,
                    extentOffset: text.length,
                  ),
          );
        }
      });
    }
  }

  void validate() {
    _formFieldKey.currentState?.validate();
  }

  // ignore: avoid_void_async
  void _onChanged(String value) async {
    if (_previousTextValue == value) return;

    _previousTextValue = value;

    widget.onChanged(
      value,
      value == widget.text ? TextFieldSource.outside : TextFieldSource.inside,
    );

    // we need to wait until the next microtask
    await Future<void>.delayed(const Duration());

    // ⚠️ validate after the new input is attached
    // we always want to validate the new input when the current state is invalid
    if (!_textFieldIsValid) {
      _formFieldKey.currentState?.validate();
    }
  }

  void _addFocusNodeListener() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);

    if (!_focusNode.hasFocus) {
      widget.onLeave?.call();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_addFocusNodeListener);

    // We only need to dispose the FocusNode by ourself
    // when we create the FocusNode by ourself.
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _selectableRegionFocusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}

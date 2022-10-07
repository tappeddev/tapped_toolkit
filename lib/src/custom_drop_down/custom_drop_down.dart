import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tapped_toolkit/tapped_toolkit.dart';

class CustomDropDown<T> extends StatefulWidget {
  final T? value;
  final void Function(T) onChanged;
  final List<DropdownItem<T>> items;
  final String? Function(T?) validator;
  final bool readOnly;

  const CustomDropDown({
    required this.value,
    required this.onChanged,
    required this.items,
    required this.validator,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  CustomDropDownState<T> createState() => CustomDropDownState<T>();
}

class CustomDropDownState<T> extends State<CustomDropDown<T>>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  final _formFieldKey = GlobalKey<FormFieldState<T>>();
  final _boxKey = GlobalKey();

  static const _itemHeight = 48.0;

  bool? _parentAutoValidate;
  bool _internalAutoValidate = false;

  Color get _borderColor => StylingTheme.of(context).shadeColor50;

  double get _cornerRadius => StylingTheme.of(context).borderRadius;

  TextStyle get _textStyle => StylingTheme.of(context).textStyleGroup.button1;

  @override
  Widget build(BuildContext context) {
    final rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    final currentWidget = widget.items
            .firstWhereOrNull((item) => item.value == widget.value)
            ?.child ??
        _buildHintText();

    final notificationColor = StylingTheme.of(context).notificationColor;

    final autoValidate = _parentAutoValidate ?? _internalAutoValidate;
    return IgnorePointer(
      ignoring: widget.readOnly,
      child: Opacity(
        opacity: widget.readOnly ? 0.5 : 1.0,
        child: FormField<T>(
          key: _formFieldKey,
          initialValue: widget.value,
          autovalidateMode: autoValidate ? AutovalidateMode.always : null,
          validator: widget.validator,
          builder: (state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CompositedTransformTarget(
                  link: _layerLink,
                  child: SizedBox(
                    key: _boxKey,
                    width: double.infinity,
                    child: _buildItem(
                      onTap: () {
                        // close the keyboard when user tap on the item
                        FocusManager.instance.primaryFocus?.unfocus();
                        _toggleDropdown();
                      },
                      border: Border.all(
                        color:
                            state.hasError ? notificationColor : _borderColor,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_cornerRadius),
                        bottom: _isOpen
                            ? Radius.zero
                            : Radius.circular(_cornerRadius),
                      ),
                      textColor: state.hasError ? notificationColor : null,
                      child: Row(
                        children: [
                          Expanded(child: currentWidget),
                          RotationTransition(
                            turns: rotateAnimation,
                            child: LocalImage.icon(
                              AppIcons.chevronDown,
                              color: state.hasError
                                  ? notificationColor
                                  : _textStyle.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.hasError)
                  Container(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      state.errorText ?? "",
                      style: StylingTheme.of(context)
                          .textStyleGroup
                          .headline5
                          .copyWith(color: notificationColor),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool validate() {
    setState(() => _internalAutoValidate = true);
    return _formFieldKey.currentState!.validate();
  }

  Widget _buildItem({
    required VoidCallback onTap,
    required Widget child,
    Key? key,
    BorderRadius? borderRadius,
    Border? border,
    Color? color,
    Color? textColor,
  }) {
    return AnimatedContainer(
      key: key,
      height: _itemHeight,
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context)
                  .style
                  .merge(_textStyle)
                  .copyWith(color: textColor),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = _boxKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final offset = renderBox.localToGlobal(Offset.zero);

    final neededHeight = offset.dy + (widget.items.length * _itemHeight);

    final mediaQuery = MediaQuery.of(context);

    final maximumAvailableHeight = mediaQuery.size.height -
        offset.dy -
        mediaQuery.padding.vertical -
        _itemHeight;

    final topOffset = offset.dy;
    return OverlayEntry(
      builder: (context) {
        final expandAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        );
        return GestureDetector(
          onTap: _toggleDropdown,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  left: offset.dx,
                  top: topOffset,
                  width: size.width,
                  child: CompositedTransformFollower(
                    offset: Offset(0, size.height),
                    link: _layerLink,
                    showWhenUnlinked: false,
                    child: SizeTransition(
                      axisAlignment: 1,
                      sizeFactor: expandAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height - topOffset,
                        ),
                        child: _buildItems(
                          maximumAvailableHeight: maximumAvailableHeight,
                          neededHeight: neededHeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItems({
    required double neededHeight,
    required double maximumAvailableHeight,
  }) {
    final shouldScroll = neededHeight > maximumAvailableHeight;

    return Container(
      constraints: BoxConstraints(maxHeight: maximumAvailableHeight),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: shouldScroll
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            _buildItem(
              key: widget.items[i].key,
              color: StylingTheme.of(context).shadeColor80,
              onTap: () {
                _toggleDropdown();
                widget.onChanged(widget.items[i].value);
              },
              border: Border(
                top: i > 0 ? BorderSide(color: _borderColor) : BorderSide.none,
                left: BorderSide(color: _borderColor),
                right: BorderSide(color: _borderColor),
                bottom: i == widget.items.length - 1
                    ? BorderSide(color: _borderColor)
                    : BorderSide.none,
              ),
              borderRadius: i == widget.items.length - 1
                  ? BorderRadius.vertical(
                      bottom: Radius.circular(_cornerRadius),
                    )
                  : null,
              child: widget.items[i].child,
            ),
          ]
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant OutlinedDropDown<T> oldWidget) {
    assert(
      AutoForm.of(context) != null,
      "$this - AutoForm need to be part of the tree",
    );

    if (oldWidget.value != widget.value) {
      onNextFrame(() {
        final newValue = widget.value;
        _formFieldKey.currentState!.didChange(newValue);
      });
    }

    _parentAutoValidate = AutoForm.of(context)!.autoValidate.value;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // only remove the entry when its open since there is an assertion that
    // check if the inner entry is not null
    if (_isOpen) {
      _overlayEntry?.remove();
    }
    _animationController.dispose();

    super.dispose();
  }

  Widget _buildHintText() {
    return Text(
      context.translate("drop_down_hint"),
      style: _textStyle.copyWith(color: StylingTheme.of(context).shadeColor50),
    );
  }

  void _toggleDropdown() async {
    if (_isOpen) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      setState(() => _isOpen = false);
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)!.insert(_overlayEntry!);
      setState(() => _isOpen = true);
      await _animationController.forward();
    }
  }
}

class DropdownItem<T> {
  final T value;
  final Widget child;
  final Key? key;

  const DropdownItem({
    required this.value,
    required this.child,
    this.key,
  });
}

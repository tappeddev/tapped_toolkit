import 'package:flutter/material.dart';
import 'package:non_uniform_border/non_uniform_border.dart';
import 'package:tapped_toolkit/src/after_first_build/on_next_frame_extension.dart';

class CustomDropDown<T> extends StatefulWidget {
  /// The selected value or null if nothing is selected.
  final T? value;

  /// Builds the button that the user can press to open the drop down.
  /// While the drop down opens use the [animation] to animate any additional
  /// widgets.
  /// Validation information is exposed in [formField] which can be used
  /// to adjust your UI if an error occurred.
  final CustomDropDownItem<T> Function(
    BuildContext context,
    Animation<double> animation,
    FormFieldState<T> formField,
  ) buildButton;

  /// Called when the user selected an item.
  final void Function(T) onChanged;

  /// The items available in the drop down.
  final List<CustomDropDownItem<T>> items;

  /// Validator function that should return an error text for the given [value].
  final String? Function(T? value)? validator;

  /// If the underlying [FormField] should auto validate or not.
  final bool autoValidate;

  /// The height of every item.
  final double itemHeight;

  /// The corner radius that animates when the drop down opens of closes
  final double cornerRadius;

  /// [TextStyle] that is provided to the items as [DefaultTextStyle].
  final TextStyle textStyle;

  /// [TextStyle] for the error that is displayed below the button.
  final TextStyle? errorStyle;

  /// Color for the border.
  final Color borderColor;

  const CustomDropDown({
    required this.value,
    required this.buildButton,
    required this.onChanged,
    required this.items,
    required this.borderColor,
    required this.textStyle,
    this.validator,
    this.errorStyle,
    this.autoValidate = false,
    this.itemHeight = 48.0,
    this.cornerRadius = 10,
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
  late final AnimationController _animationController;

  final _formFieldKey = GlobalKey<FormFieldState<T>>();
  final _boxKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveDecoration =
        const InputDecoration().applyDefaults(theme.inputDecorationTheme);

    return FormField<T>(
      key: _formFieldKey,
      initialValue: widget.value,
      autovalidateMode: widget.autoValidate
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
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
                  onTap: _toggleDropdown,
                  border: Border.all(
                    color: state.hasError
                        ? theme.colorScheme.error
                        : widget.borderColor,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(widget.cornerRadius),
                    bottom: _isOpen
                        ? Radius.zero
                        : Radius.circular(widget.cornerRadius),
                  ),
                  item: widget.buildButton(
                    context,
                    _animationController,
                    _formFieldKey.currentState!,
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
                  style: widget.errorStyle ??
                      effectiveDecoration.errorStyle ??
                      theme.textTheme.bodySmall!
                          .copyWith(color: theme.colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }

  bool validate() => _formFieldKey.currentState!.validate();

  Widget _buildItem({
    required VoidCallback onTap,
    required CustomDropDownItem<T> item,
    required BorderRadius? borderRadius,
    required Border? border,
  }) {
    return AnimatedContainer(
      key: item.key,
      height: widget.itemHeight,
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: DefaultTextStyle(
            style: widget.textStyle,
            child: item.child,
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = _boxKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final offset = renderBox.localToGlobal(Offset.zero);

    final neededHeight = offset.dy + (widget.items.length * widget.itemHeight);

    final mediaQuery = MediaQuery.of(context);

    final maximumAvailableHeight =
        mediaQuery.size.height - offset.dy - mediaQuery.viewPadding.vertical;

    final topOffset = offset.dy + widget.itemHeight + mediaQuery.padding.bottom;

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

    final borderSide = BorderSide(color: widget.borderColor);
    final radius = Radius.circular(widget.cornerRadius);

    return Material(
      clipBehavior: Clip.hardEdge,
      shape: NonUniformBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: radius,
          bottomRight: radius,
        ),
        topWidth: 0,
        color: borderSide.color,
        bottomWidth: borderSide.width,
        leftWidth: borderSide.width,
        rightWidth: borderSide.width,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: shouldScroll
            ? const ClampingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            _buildItem(
              onTap: () {
                _toggleDropdown();

                final selectedValue = widget.items[i].value;

                widget.onChanged(selectedValue as T);
              },
              border: Border(
                top: i > 0 || widget.items.length == 1
                    ? borderSide
                    : BorderSide.none,
                left: borderSide,
                right: borderSide,
                bottom:
                    i == widget.items.length - 1 ? borderSide : BorderSide.none,
              ),
              borderRadius: i == widget.items.length - 1
                  ? BorderRadius.vertical(
                      bottom: radius,
                    )
                  : null,
              item: widget.items[i],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      onNextFrame(() => _formFieldKey.currentState!.didChange(widget.value));
    }
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

  Future<void> _toggleDropdown() async {
    if (_isOpen) {
      await _animationController.reverse();
      _overlayEntry?.remove();
      setState(() => _isOpen = false);
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
      await _animationController.forward();
    }
  }
}

/// A simple data class that holds all the data of an item.
class CustomDropDownItem<T> {
  /// The value of the item or null if the item
  /// is returned in [CustomDropDown.buildButton].
  final T? value;

  /// The widget for the given [value].
  final Widget child;

  /// The color that is visible behind the [child].
  final Color backgroundColor;

  /// The direct key of the widget that [child] is wrapped in.
  final Key? key;

  const CustomDropDownItem({
    required this.value,
    required this.child,
    required this.backgroundColor,
    this.key,
  });
}

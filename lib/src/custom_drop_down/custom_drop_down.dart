import 'package:flutter/material.dart';
import 'package:tapped_toolkit/src/after_first_build/on_next_frame_extension.dart';

class CustomDropDown<T> extends StatefulWidget {
  final T? value;
  final CustomDropDownItem<T> Function(
    BuildContext context,
    Animation<double> animation,
    FormFieldState<T> formField,
  ) buildItem;
  final void Function(T) onChanged;
  final List<CustomDropDownItem<T>> items;
  final String? Function(T?) validator;
  final bool autoValidate;
  final double itemHeight;
  final double cornerRadius;

  final TextStyle defaultTextStyle;

  final Color borderColor;

  const CustomDropDown({
    required this.value,
    required this.buildItem,
    required this.onChanged,
    required this.items,
    required this.validator,
    required this.borderColor,
    required this.defaultTextStyle,
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
                    color:
                        state.hasError ? theme.errorColor : widget.borderColor,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(widget.cornerRadius),
                    bottom: _isOpen
                        ? Radius.zero
                        : Radius.circular(widget.cornerRadius),
                  ),
                  item: widget.buildItem(
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
                  style: effectiveDecoration.errorStyle!
                      .copyWith(color: theme.errorColor),
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
            style: widget.defaultTextStyle,
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

    final maximumAvailableHeight = mediaQuery.size.height -
        offset.dy -
        mediaQuery.padding.vertical -
        widget.itemHeight;

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
              onTap: () {
                _toggleDropdown();

                final selectedValue = widget.items[i].value;

                widget.onChanged(selectedValue as T);
              },
              border: Border(
                top: i > 0
                    ? BorderSide(color: widget.borderColor)
                    : BorderSide.none,
                left: BorderSide(color: widget.borderColor),
                right: BorderSide(color: widget.borderColor),
                bottom: i == widget.items.length - 1
                    ? BorderSide(color: widget.borderColor)
                    : BorderSide.none,
              ),
              borderRadius: i == widget.items.length - 1
                  ? BorderRadius.vertical(
                      bottom: Radius.circular(widget.cornerRadius),
                    )
                  : null,
              item: widget.items[i],
            ),
          ]
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
      Overlay.of(context)!.insert(_overlayEntry!);
      setState(() => _isOpen = true);
      await _animationController.forward();
    }
  }
}

class CustomDropDownItem<T> {
  final T? value;
  final Widget child;
  final Color backgroundColor;
  final Key? key;

  const CustomDropDownItem({
    required this.value,
    required this.child,
    required this.backgroundColor,
    this.key,
  });
}

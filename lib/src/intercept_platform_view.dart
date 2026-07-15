import 'package:flutter/cupertino.dart';
import 'package:universal_platform/universal_platform.dart';

/// Inspirited of: https://pub.dev/packages/pointer_interceptor
///
/// 😵‍💫 Whats the problem?
/// When overlaying Flutter widgets on top of HtmlElementView/PlatformView widgets
/// that respond to mouse gestures (handle clicks, for example),
/// the clicks will be consumed by the HtmlElementView/PlatformView,
/// and not relayed to Flutter.
/// The result is that Flutter widget's onTap (and other) handlers won't fire as expected,
/// but they'll affect the underlying native platform view.
///
/// 🔎 Where do we have an problem?
/// We had issues that the [VectorMap] received events from the Flutter widgets above.
class InterceptPlatformView extends StatelessWidget {
  final Widget child;

  final bool intercepting;

  const InterceptPlatformView({
    this.intercepting = true,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isWeb) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (intercepting)
            // We need to add the HtmlElementView <div> to prevent events are captured by an underlying HtmlElementView in web.
            ExcludeFocus(
              child: Positioned.fill(
                child: HtmlElementView.fromTagName(
                  tagName: 'div',
                  isVisible: false,
                ),
              ),
            ),
          child,
        ],
      );
    }
    return child;
  }
}

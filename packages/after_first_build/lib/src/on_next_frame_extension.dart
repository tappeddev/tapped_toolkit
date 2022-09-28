import 'dart:async';

import 'package:flutter/cupertino.dart';

extension OnNextFrameExtension<T extends StatefulWidget> on State<T> {
  Future<void> onNextFrame(FutureOr<void> Function() method) {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        completer.complete(method());
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
      }
    });
    return completer.future;
  }
}

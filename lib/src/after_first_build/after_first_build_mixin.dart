import 'package:tapped_toolkit/src/after_first_build/on_next_frame_extension.dart';
import 'package:flutter/cupertino.dart';

mixin AfterFirstBuildMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();

    onNextFrame(afterFirstBuild);
  }

  void afterFirstBuild();
}

import 'package:flutter/material.dart';
import 'package:tapped_toolkit/tapped_toolkit.dart';

class DropDownExample extends StatefulWidget {
  final int numberOfEntries;

  const DropDownExample({
    Key? key,
    required this.numberOfEntries,
  }) : super(key: key);

  @override
  State<DropDownExample> createState() => _DropDownExample();
}

class _DropDownExample extends State<DropDownExample> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final elements = _getDropDownElements();

    return CustomDropDown(
      value: _index,
      buildButton: (_, __, state) {
        return elements[state.value!];
      },
      onChanged: (currentIndex) {
        setState(() {
          _index = currentIndex;
        });
      },
      items: elements,
      borderColor: Colors.red,
      textStyle: const TextStyle(),
    );
  }

  List<CustomDropDownItem> _getDropDownElements() {
    return [
      for (int i = 0; i < widget.numberOfEntries; i++)
        CustomDropDownItem<int>(
          value: i,
          child: ListElement(title: "$i. Element"),
          backgroundColor: Colors.yellow,
        ),
    ];
  }
}

class ListElement extends StatelessWidget {
  final String title;

  const ListElement({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
    );
  }
}

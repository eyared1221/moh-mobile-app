import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final void Function(T?)? onChanged;
  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
  }); // use super.key

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }
}

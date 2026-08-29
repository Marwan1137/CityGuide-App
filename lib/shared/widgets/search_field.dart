import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    required this.onChanged,
    this.controller,
    this.hintText = 'Search places or cities',
    super.key,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
    ),
  );
}

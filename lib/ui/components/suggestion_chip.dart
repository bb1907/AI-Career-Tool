import 'package:flutter/material.dart';

class SuggestionChip extends StatelessWidget {
  const SuggestionChip({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.add, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

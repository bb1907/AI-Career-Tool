import 'dart:async';

import 'package:flutter/material.dart';

class AILoadingIndicator extends StatefulWidget {
  const AILoadingIndicator({
    super.key,
    this.messages = const [
      'Analyzing your experience...',
      'Matching skills with job requirements...',
      'Crafting your professional summary...',
    ],
    this.alignment = CrossAxisAlignment.center,
  });

  final List<String> messages;
  final CrossAxisAlignment alignment;

  @override
  State<AILoadingIndicator> createState() => _AILoadingIndicatorState();
}

class _AILoadingIndicatorState extends State<AILoadingIndicator> {
  Timer? _messageTimer;
  Timer? _dotsTimer;
  int _messageIndex = 0;
  int _dots = 1;

  @override
  void initState() {
    super.initState();
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || widget.messages.isEmpty) {
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % widget.messages.length;
      });
    });
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _dots = _dots == 3 ? 1 : _dots + 1;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = widget.messages.isEmpty
        ? 'Analyzing'
        : widget.messages[_messageIndex];

    return Column(
      crossAxisAlignment: widget.alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Text(
                '$message${'.' * _dots}',
                key: ValueKey<String>('$message$_dots'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

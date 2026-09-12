import 'dart:async';
import 'package:flutter/material.dart';

const List<String> kMembershipStatusMessages = <String>[
  'Connecting to OmniToolkit services...',
  'Verifying purchase history...',
  'Restoring Lifetime Access...',
];

class StagedLoader extends StatefulWidget {
  final String heading;
  final List<String> messages;

  const StagedLoader({
    super.key,
    this.heading = 'Checking Membership...',
    this.messages = kMembershipStatusMessages,
  });

  @override
  State<StagedLoader> createState() => _StagedLoaderState();
}

class _StagedLoaderState extends State<StagedLoader> {
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;
      setState(() => _i = (_i + 1) % widget.messages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            widget.heading,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.messages[_i],
              key: ValueKey(_i),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
}
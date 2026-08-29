/// FILE: lib/modules/clipper/screens/clipper_screen.dart
import 'package:flutter/material.dart';

import '../widgets/clip_input_field.dart';
import '../widgets/clip_list.dart';
import '../widgets/password_generator_widget.dart';

class ClipperScreen extends StatelessWidget {
  const ClipperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clipper & Password Generator'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.content_cut), text: 'Clips'),
              Tab(icon: Icon(Icons.password), text: 'Password'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ClipsTab(),
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PasswordGeneratorWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClipsTab extends StatelessWidget {
  const _ClipsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ClipInputField(),
        SizedBox(height: 16),
        ClipList(),
      ],
    );
  }
}

/// FILE: lib/modules/calculator/screens/calculator_screen.dart
import 'package:flutter/material.dart';

import 'date_difference_tab.dart';
import 'scientific_calculator_tab.dart';
import 'simple_calculator_tab.dart';
import 'unit_converter_tab.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.calculate_outlined), text: 'Simple'),
              Tab(icon: Icon(Icons.functions), text: 'Scientific'),
              Tab(icon: Icon(Icons.date_range), text: 'Date Diff'),
              Tab(icon: Icon(Icons.swap_horiz), text: 'Converter'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SimpleCalculatorTab(),
            ScientificCalculatorTab(),
            DateDifferenceTab(),
            UnitConverterTab(),
          ],
        ),
      ),
    );
  }
}

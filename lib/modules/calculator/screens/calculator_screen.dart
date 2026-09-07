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
        body: SafeArea(
          child: Column(
            children: [
              // Compact TabBar without large title header to maximize viewport
              const Material(
                elevation: 1,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(icon: Icon(Icons.calculate_outlined, size: 20), text: 'Standard'),
                    Tab(icon: Icon(Icons.functions, size: 20), text: 'Scientific'),
                    Tab(icon: Icon(Icons.date_range, size: 20), text: 'Date Calculator'),
                    Tab(icon: Icon(Icons.swap_horiz, size: 20), text: 'Unit Converter'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    SimpleCalculatorTab(),
                    ScientificCalculatorTab(),
                    DateDifferenceTab(),
                    UnitConverterTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

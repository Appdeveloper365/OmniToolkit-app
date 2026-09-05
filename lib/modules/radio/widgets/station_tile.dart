/// FILE: lib/modules/radio/widgets/station_tile.dart
import 'package:flutter/material.dart';
import '../models/station_model.dart';
import 'station_card.dart';

class StationTile extends StatelessWidget {
  const StationTile({super.key, required this.station});
  final StationModel station;

  @override
  Widget build(BuildContext context) {
    return StationCard(station: station);
  }
}

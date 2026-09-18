import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/membership/membership_service.dart';

class ActiveDevicesScreen extends StatefulWidget {
  const ActiveDevicesScreen({super.key});

  @override
  State<ActiveDevicesScreen> createState() => _ActiveDevicesScreenState();
}

class _ActiveDevicesScreenState extends State<ActiveDevicesScreen> {
  final _service = MembershipService();
  bool _loading = true;
  bool _removing = false;
  String? _error;
  String _currentDeviceId = '';
  MembershipState? _state;
  List<ActiveDevice> _devices = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.emailVerified != true) {
        throw StateError('Verify your purchase email to manage active devices.');
      }
      final identity = await _service.currentDeviceIdentity();
      final state = await _service.startOrRestore();
      final devices = await _service.listActiveDevices();
      if (!mounted) return;
      setState(() {
        _currentDeviceId = identity.deviceId;
        _state = state;
        _devices = devices;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is StateError
            ? error.message
            : 'Could not load active devices right now. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _removeDevice(ActiveDevice device) async {
    if (_removing) return;
    if (device.deviceId == _currentDeviceId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This device cannot be removed while it is in use.'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove device?'),
            content: Text(
              'Remove ${device.platform.toUpperCase()} (${maskDeviceId(device.deviceId)}) from this membership?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _removing = true);
    try {
      final devices = await _service.removeActiveDevice(device.deviceId);
      final state = await _service.startOrRestore();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _state = state;
        _removing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device removed.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _removing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove the device right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      appBar: AppBar(title: const Text('Active Devices')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (state != null && state.deviceLimitReached) ...[
                        Card(
                          color: Colors.orange.shade50,
                          child: const ListTile(
                            leading: Icon(Icons.warning_amber_rounded,
                                color: Colors.deepOrange),
                            title: Text(
                              'Device Limit Reached',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'This membership is active on the maximum number of devices.',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        'Active devices: ${_devices.length} / ${state?.maxActiveDevices ?? 3}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (_devices.isEmpty)
                        const Card(
                          child: ListTile(
                            title: Text('No active devices found.'),
                          ),
                        ),
                      ..._devices.map((device) {
                        final isCurrentDevice =
                            device.deviceId == _currentDeviceId;
                        return ActiveDeviceCard(
                          device: device,
                          isCurrentDevice: isCurrentDevice,
                          onRemove: _removing || isCurrentDevice
                              ? null
                              : () => _removeDevice(device),
                          formatDate: _formatDate,
                        );
                      }),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Unknown';
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class ActiveDeviceCard extends StatelessWidget {
  const ActiveDeviceCard({
    super.key,
    required this.device,
    required this.isCurrentDevice,
    required this.onRemove,
    required this.formatDate,
  });

  final ActiveDevice device;
  final bool isCurrentDevice;
  final VoidCallback? onRemove;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCurrentDevice
                      ? Icons.smartphone_rounded
                      : Icons.devices_other_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${device.platform.toUpperCase()}${isCurrentDevice ? ' (This device)' : ''}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: isCurrentDevice
                      ? 'This device cannot be removed while in use'
                      : 'Remove device',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Device ID: ${maskDeviceId(device.deviceId)}'),
            const SizedBox(height: 4),
            Text('First seen: ${formatDate(device.firstSeen)}'),
            const SizedBox(height: 4),
            Text('Last seen: ${formatDate(device.lastSeen)}'),
          ],
        ),
      ),
    );
  }
}

String maskDeviceId(String value) {
  final trimmed = value.trim();
  if (trimmed.length <= 8) return trimmed;
  return '${trimmed.substring(0, 4)}…${trimmed.substring(trimmed.length - 4)}';
}

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../membership/membership_service.dart';

class PremiumMembershipScreen extends StatelessWidget {
  const PremiumMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Membership')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.devices_rounded, color: Colors.blue),
              title: const Text('Active Devices',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Manage devices using this membership'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ActiveDevicesScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveDevicesScreen extends StatefulWidget {
  const ActiveDevicesScreen({super.key});

  @override
  State<ActiveDevicesScreen> createState() => _ActiveDevicesScreenState();
}

class _ActiveDevicesScreenState extends State<ActiveDevicesScreen> {
  final _membershipService = MembershipService();
  bool _loading = true;
  List<MembershipDevice> _devices = const [];
  String? _error;
  String? _currentDeviceId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final currentDeviceId = await _membershipService.deviceId();
      final devices = await _membershipService.listActiveDevices();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _currentDeviceId = currentDeviceId;
        _loading = false;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = MembershipService.functionsErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'We could not load active devices right now.';
      });
    }
  }

  Future<void> _removeDevice(MembershipDevice device) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Remove Device'),
            content: Text(
                'Remove ${device.platform} (${device.deviceId}) from active devices?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await _membershipService.removeActiveDevice(device.deviceId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Device removed.'),
      ));
      await _load();
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(MembershipService.functionsErrorMessage(error))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not remove device right now.'),
      ));
    }
  }

  String _fmtDate(DateTime? value) {
    if (value == null) return 'Unknown';
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Devices')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Active devices: ${_devices.length}/3',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      if (_devices.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No active devices found.'),
                          ),
                        ),
                      for (final device in _devices)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.smartphone),
                            title: Text(
                              '${device.platform.isEmpty ? 'unknown' : device.platform}'
                              '${device.deviceId == _currentDeviceId ? ' (This device)' : ''}',
                            ),
                            subtitle: Text(
                              'Device ID: ${device.deviceId}\n'
                              'First seen: ${_fmtDate(device.firstSeen)}\n'
                              'Last seen: ${_fmtDate(device.lastSeen)}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: 'Remove',
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () => _removeDevice(device),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

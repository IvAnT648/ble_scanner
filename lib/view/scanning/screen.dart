import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ble_device.dart';
import 'bloc.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanningScreenBloc, ScanningScreenState>(
      buildWhen: (previous, current) => current is! LoadingScanningScreenState,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('BLE Scanner'),
            actions: [
              _AppBarButton(
                icon: Icons.not_started,
                color: Colors.green,
                isActive: state is ScanningIsStoppedScreenState ||
                    state is BtIsNotAvailableScreenState ||
                    state is FailureScanningScreenState,
                onTap: context.read<ScanningScreenBloc>().start,
              ),
              _AppBarButton(
                icon: Icons.stop_circle,
                color: Colors.red,
                isActive: state is ScanningIsRunningScreenState,
                onTap: context.read<ScanningScreenBloc>().stop,
              ),
            ],
          ),
          body: switch (state) {
            LoadingScanningScreenState _ => const SizedBox(),
            ScanningIsStoppedScreenState _ => const _StoppedState(),
            ScanningIsRunningScreenState s => _ScanningState(s.devices),
            FailureScanningScreenState s => _FailureState(s.msg),
            BtIsNotAvailableScreenState _ => const _BtNotAvailable(),
          },
        );
      },
    );
  }
}

class _AppBarButton extends StatelessWidget {
  static const double _iconSize = 36;

  final VoidCallback onTap;
  final IconData icon;
  final bool isActive;
  final Color color;

  const _AppBarButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isActive ? onTap : null,
      padding: EdgeInsets.zero,
      color: color,
      icon: Icon(icon, size: _iconSize),
    );
  }
}

class _StoppedState extends StatelessWidget {
  const _StoppedState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Text('Start scanning to see available devices'),
        ],
      ),
    );
  }
}

class _ScanningState extends StatelessWidget {
  final Set<BleDevice> data;

  const _ScanningState(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...data.map((e) => _DeviceListItem(e)),
        ],
      ),
    );
  }
}

class _DeviceListItem extends StatelessWidget {
  final BleDevice data;

  const _DeviceListItem(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.name.isEmpty ? 'N/A' : data.name),
              Text(data.macAddress),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.signal_cellular_alt),
              Text('${data.rssi.toString()} dBm'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FailureState extends StatelessWidget {
  final String msg;

  const _FailureState(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Text(msg, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

class _BtNotAvailable extends StatelessWidget {
  const _BtNotAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Text(
            'Sorry, bluetooth is not available now...',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

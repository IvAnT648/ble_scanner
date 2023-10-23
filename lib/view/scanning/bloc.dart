import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../data/ble_device.dart';

sealed class ScanningScreenState {}

class LoadingScanningScreenState implements ScanningScreenState {}

class ScanningIsStoppedScreenState implements ScanningScreenState {}

class ScanningIsRunningScreenState implements ScanningScreenState {
  final Set<BleDevice> devices;

  ScanningIsRunningScreenState(this.devices);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScanningIsRunningScreenState &&
            runtimeType == other.runtimeType &&
            setEquals(devices, other.devices);
  }

  @override
  int get hashCode => devices.hashCode;
}

class FailureScanningScreenState implements ScanningScreenState {
  final String msg;

  FailureScanningScreenState(this.msg);
}

class BtIsNotAvailableScreenState implements ScanningScreenState {}

class ScanningScreenBloc extends Cubit<ScanningScreenState> {
  final Set<BleDevice> _scanned = {};
  StreamSubscription? _scanningSubscription;
  StreamSubscription? _adapterStateSubscription;

  ScanningScreenBloc() : super(LoadingScanningScreenState()) {
    _init();
  }

  void _init() async {
    if (!(await FlutterBluePlus.isSupported)) {
      emit(
          FailureScanningScreenState('Bluetooth not supported by this device'));
      return;
    }

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print('BluetoothAdapterState is $state');
      if (state == BluetoothAdapterState.on) {
        emit(ScanningIsStoppedScreenState());
      } else {
        emit(BtIsNotAvailableScreenState());
      }
    });

    _scanningSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        _scanned.clear();
        emit(LoadingScanningScreenState());
        for (final el in results) {
          _scanned.add(BleDevice(
            name: el.device.platformName,
            macAddress: el.device.remoteId.str,
            rssi: el.rssi,
          ));
        }
        emit(ScanningIsRunningScreenState(_scanned));
      },
      onError: (e) => print(e),
    );
  }

  void start() async {
    await FlutterBluePlus.startScan();
  }

  void stop() async {
    await FlutterBluePlus.stopScan();
    emit(ScanningIsStoppedScreenState());
  }

  @override
  Future<void> close() {
    _adapterStateSubscription?.cancel();
    _scanningSubscription?.cancel();
    return super.close();
  }
}

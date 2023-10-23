
class BleDevice {
  late final String name;
  final String macAddress;
  final int rssi;

  BleDevice({
    required this.name,
    required this.macAddress,
    required this.rssi,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice &&
          runtimeType == other.runtimeType &&
          macAddress == other.macAddress;

  @override
  int get hashCode => macAddress.hashCode;
}

class SensorData {
  final double temperature;
  final double liveWeight;

  SensorData({this.temperature = 0.0, this.liveWeight = 0.0});

  // Updated to match your RTDB field names: 'temp' and 'weight'
  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    if (map == null) {
      return SensorData();
    }
    return SensorData(
      temperature: (map['temp'] as num?)?.toDouble() ?? 0.0,
      liveWeight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
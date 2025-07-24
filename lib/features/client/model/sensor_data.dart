class SensorData {
  final double temperature;
  final double liveWeight;

  SensorData({this.temperature = 0.0, this.liveWeight = 0.0});


  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    return SensorData(
      temperature: (map['temp'] as num?)?.toDouble() ?? 0.0,
      liveWeight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

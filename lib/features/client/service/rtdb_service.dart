import 'package:firebase_database/firebase_database.dart';
import 'package:cw_app/features/client/model/sensor_data.dart';

class RtdbService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // This method is now much simpler.
  Stream<SensorData> getSensorDataStream() {
    final ref = _database.ref('live');

    return ref.onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final dataMap = event.snapshot.value as Map<dynamic, dynamic>;
        return SensorData.fromMap(dataMap);
      } else {
        return SensorData(); 
      }
    });
  }
}
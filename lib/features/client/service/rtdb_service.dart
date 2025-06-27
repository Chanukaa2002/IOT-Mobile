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

  Stream<Map<String, Map<String, double>>> getContainerWeightsStream() {
    final ref = _database.ref('container_weights');
    return ref.onValue.map((event) {
      final Map<String, Map<String, double>> allMeals = {};

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((mealType, containers) {
          if (mealType != null && containers is List<dynamic>) {
            final Map<String, double> containerWeights = {};

            // Skip index 0 (null) and start from 1
            for (int i = 1; i < containers.length; i++) {
              if (containers[i] != null) {
                containerWeights[i.toString()] =
                    (containers[i] is num)
                        ? (containers[i] as num).toDouble()
                        : 0.0;
              }
            }

            allMeals[mealType.toString()] = containerWeights;
          }
        });
      }

      print('Processed container weights: $allMeals'); // Debug log
      return allMeals;
    });
  }

  Future<void> resetMealContainerWeights(String mealType) async {
    try {
      final ref = _database.ref('container_weights');
      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        String? firebaseKey;

        // Find the matching key in Firebase (e.g., "Breckfast" for "Breakfast")
        final normalizedMealType = mealType.toLowerCase().replaceAll(
          'breckfast',
          'breakfast',
        );
        firebaseKey =
            data.keys
                .firstWhere(
                  (k) =>
                      k.toString().toLowerCase().replaceAll(
                        'breckfast',
                        'breakfast',
                      ) ==
                      normalizedMealType,
                  orElse: () => null,
                )
                ?.toString();

        if (firebaseKey != null) {
          // Get a reference to the specific meal node (e.g., .../container_weights/Breckfast)
          final mealRef = ref.child(firebaseKey);

          // Remove the entire node. This is cleaner than setting values to 0.
          // The UI will update automatically via the stream listener.
          await mealRef.remove();
          print(
            "Successfully removed meal node '$firebaseKey' to reset weights.",
          );
        } else {
          print("Could not find meal type '$mealType' in Firebase to reset.");
        }
      }
    } catch (e) {
      print("Error resetting container weights: $e");
      throw Exception("Could not reset weights in Firebase.");
    }
  }
}

import 'package:intl/intl.dart';
import 'package:dart_date/dart_date.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';

class Sample {
  int maxWeight;
  String sampleID;
  DateTime lastChecked;

  Sample({this.maxWeight, this.lastChecked, this.sampleID});

  bool needsUpdate() {
    if (lastChecked.isSameDay(DateTime.now().subtract(Duration(hours: 12))))
      return false;
    return true;
  }

  void updateSample(int sample, PlantCollection plantCollection) {
    //update plants
    lastChecked = DateTime.now().subtract(Duration(hours: 12));
    lastChecked =
        DateTime(lastChecked.year, lastChecked.month, lastChecked.day);

    plantCollection.plantList.forEach((element) {
      element.updateSample(sampleID, (maxWeight - sample));
    });

    plantCollection.orderCollection(false);
  }

  Map<String, dynamic> toJson() => {
        'maxWeight': maxWeight,
        'sampleID': sampleID,
        'lastChecked': lastChecked != null
            ? DateFormat('yyyy-MM-dd').format(lastChecked)
            : null,
      };
}

import 'dart:math';
import 'package:intl/intl.dart';

class Plant {
  int uid;
  String name;
  DateTime previousWater;
  DateTime lastWatered;
  DateTime nextWater;
  int dbw;
  double multiplier;

  Plant(
      {this.uid,
      this.name,
      this.previousWater,
      this.lastWatered,
      this.nextWater,
      this.dbw,
      this.multiplier});

  void waterPlant() {
    previousWater = lastWatered;
    lastWatered = DateTime.now();
    dbw = max(1, lastWatered.difference(previousWater).inDays);
    multiplier = 0.75;
    nextWater = suggestedWaterDate();
  }

  void checkPlant() {
    multiplier += 0.25;
  }

  DateTime suggestedWaterDate() {
    return lastWatered
        .add(new Duration(days: max((dbw.toDouble() * multiplier).round(), 1)));
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'lastWatered': DateFormat('yyyy-MM-dd').format(lastWatered),
        'nextWater': DateFormat('yyyy-MM-dd').format(nextWater),
        'previousWater': DateFormat('yyyy-MM-dd').format(previousWater),
        'dbw': dbw,
        'multiplier': multiplier,
      };
}

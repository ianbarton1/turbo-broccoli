import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Plant {
  int uid;
  String name;
  DateTime previousWater;
  DateTime lastWatered;
  DateTime nextWater;
  int dbw;
  double multiplier;
  int section;
  int zone;
  int checkStatus = 0;

  Plant(
      {this.uid,
      this.name,
      this.previousWater,
      this.lastWatered,
      this.nextWater,
      this.dbw,
      this.multiplier,
      this.section,
      this.zone,
      this.checkStatus});

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
    return lastWatered.add(
        new Duration(days: max((dbw.toDouble() * multiplier).round(), -30)));
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'lastWatered': lastWatered != null
            ? DateFormat('yyyy-MM-dd').format(lastWatered)
            : null,
        'nextWater': nextWater != null
            ? DateFormat('yyyy-MM-dd').format(nextWater)
            : null,
        'previousWater': previousWater != null
            ? DateFormat('yyyy-MM-dd').format(previousWater)
            : null,
        'dbw': dbw,
        'multiplier': multiplier,
        'checkStatus': checkStatus,
        'section': section,
        'zone': zone,
      };
}

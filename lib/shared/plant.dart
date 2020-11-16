import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:dart_date/dart_date.dart';

class Plant {
  int uid;
  String name;
  DateTime previousWater;
  DateTime lastWatered;
  DateTime nextWater;
  DateTime activeWatered;
  int dbw;
  double multiplier;
  int section;
  int zone;
  int checkStatus = 0;
  int dbw_low;
  int dbw_high;

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
      this.checkStatus,
      this.activeWatered});

  void waterPlant() {
    previousWater = activeWatered;
    activeWatered = nextWater;
    lastWatered = DateTime.now();
    dbw = max(1, activeWatered.difference(previousWater).inDays);
    multiplier = 0.75;
    nextWater = suggestedWaterDate();
    checkStatus = 0;
  }

  void checkPlant() {
    DateTime nextWaterBefore = nextWater;
    multiplier += 0.25;
    nextWater = suggestedWaterDate();
    if (nextWater.isSameDay(nextWaterBefore) ||
        nextWater.isBefore(nextWaterBefore))
      nextWater = nextWaterBefore.add(Duration(days: 1));
    checkStatus = 0;
  }

  DateTime suggestedWaterDate() {
    return lastWatered
        .add(new Duration(days: max((dbw.toDouble() * multiplier).round(), 1)));
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
        'activeWatered': activeWatered != null
            ? DateFormat('yyyy-MM-dd').format(activeWatered)
            : null,
        'dbw': dbw,
        'multiplier': multiplier,
        'checkStatus': checkStatus,
        'section': section,
        'zone': zone,
      };
}

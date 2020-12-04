import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:dart_date/dart_date.dart';

class Plant {
  int uid;
  String name;
  //previousWater holds the date that the plant was last previously watered
  DateTime previousWater;
  //holds the actual date that a plant was watered
  DateTime lastWatered;
  //holds when the plant would ideally be watered or checked next
  DateTime nextWater;
  //holds when a plant should have been watered regardless of whether that's the actual date
  DateTime activeWatered;
  //holds when a plant will be checked next after load balancing has been applied
  DateTime scheduleDate;
  //a delayFactor that will be applied between a DateRange DDMM-DDMM
  double delayFactor;
  //holds the range that the delayFactor will be applied between
  DateTimeRange delayPeriod;

  int dbw;
  double multiplier;
  int section;
  int zone;
  int checkStatus = 0;
  int dbwLow = 1;
  int dbwHigh = 100;
  String homeZone;

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
      this.activeWatered,
      this.homeZone,
      this.dbwLow,
      this.dbwHigh}) {
    if (this.dbwLow == null) this.dbwLow = 1;
    if (this.dbwHigh == null) this.dbwHigh = 100;
  }

  void waterPlant() {
    previousWater = activeWatered;
    activeWatered = nextWater;
    lastWatered = DateTime.now();
    dbw = min(
        max(dbwLow, activeWatered.difference(previousWater).inDays), dbwHigh);
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
        'homeZone': homeZone,
        'dbwLow': dbwLow,
        'dbwHigh': dbwHigh,
      };
}

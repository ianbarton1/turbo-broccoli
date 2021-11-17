import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:dart_date/dart_date.dart';
import 'package:sqflite/sqflite.dart';

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
  //plant has been checked previously?
  bool waterMode = false;
  //is this plant a delayed plant
  bool isDelayed = false;
  //how much to delay the plant by
  double delayFactor = 2;
  //SampleID: the string which identifies the sample to use
  String sampleID;

  //sample data for dynamic plants;
  bool isPlantDynamic = false;
  double lastActivitySum = 0;
  int lastActivitySampleCount = 0;
  double currentActivitySum = 0;
  int currentActivitySampleCount = 0;

  int dbw;
  double multiplier;
  int section;
  int zone;
  int checkStatus = 0;
  int dbwLow = 1;
  int dbwHigh = 100;
  String homeZone;
  int loadBalancingOffset = 0;
  bool _holidayMode = false;
  Image plantImage;
  DateTime plantDateTime;
  Database database;
  dynamic tempImage;

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
      this.dbwHigh,
      this.waterMode,
      this.delayFactor,
      this.isDelayed,
      this.currentActivitySampleCount,
      this.currentActivitySum,
      this.isPlantDynamic,
      this.lastActivitySampleCount,
      this.lastActivitySum,
      this.sampleID,
      this.loadBalancingOffset,
      this.database}) {
    if (this.dbwLow == null) this.dbwLow = 1;
    if (this.dbwHigh == null) this.dbwHigh = 100;
    if (this.isPlantDynamic == null) this.isPlantDynamic = false;
    if (this.sampleID == null) this.sampleID = '';
    if (this.currentActivitySampleCount == null) currentActivitySampleCount = 0;
    if (this.currentActivitySum == null) currentActivitySum = 0;
    if (this.lastActivitySampleCount == null) lastActivitySampleCount = 0;
    if (this.lastActivitySum == null) lastActivitySum = 0;
    if (this.isDelayed == null) isDelayed = false;
    if (this.waterMode == null) waterMode = false;
    if (this.delayFactor == null) delayFactor = 2;
    if (this.dbw == null) dbw = 7;
    if (this.loadBalancingOffset == null) loadBalancingOffset = 0;

    getDatabaseImage();
  }

  Future<void> getDatabaseImage() async {
    tempImage = await database.query("plant_images",
        columns: ["image", "date_time"],
        where: 'plantid = ?',
        whereArgs: [uid],
        limit: 20,
        orderBy: "date_time DESC");
    plantDateTime = new DateTime.fromMillisecondsSinceEpoch(
        (tempImage[2]['date_time'] * 1000));
    tempImage = tempImage[2]['image'];
    plantImage = new Image.memory(tempImage);
  }

  DateTime safeDateTime(DateTime unsafeDateTime) {
    return DateTime(
        unsafeDateTime.year, unsafeDateTime.month, unsafeDateTime.day);
  }

  void setWateringDates() {
    previousWater = activeWatered;
    activeWatered = nextWater;
  }

//this method waters the plant and updates all the values to with that.
  void waterPlant() {
    if (waterMode == false && isDelayed) {
      multiplier *= delayFactor;
      waterMode = true;
      checkStatus = 0;
      setWateringDates();
      nextWater = suggestedWaterDate();
    } else {
      //we're only going to update the measurement dates if the plant has not been delayed before
      if (waterMode == false) setWateringDates();
      lastWatered = DateTime.now();
      dbw = (activeWatered.difference(previousWater).inDays).round();
      multiplier = 0.75;

      if (isPlantDynamic) {
        lastActivitySampleCount = currentActivitySampleCount;
        lastActivitySum = currentActivitySum;
        currentActivitySampleCount = 0;
        currentActivitySum = 0;
      }
      nextWater = suggestedWaterDate();
      checkStatus = 0;
      waterMode = false;
    }
  }

//this method updates the values if the plant has only been checked (no water)
  void checkPlant() {
    DateTime nextWaterBefore = nextWater;
    multiplier += 0.25;
    nextWater = suggestedWaterDate();
    if (nextWater.isSameDay(nextWaterBefore) ||
        nextWater.isBefore(nextWaterBefore))
      nextWater = nextWaterBefore.add(Duration(days: 1));
    checkStatus = 0;
  }

//this small method returns the next suggested date to check a plant
  DateTime suggestedWaterDate() {
    //calculate the ideal real dbw
    double realDbw =
        (dbw.toDouble() * multiplier * dynamicMultiplier()).round().toDouble();

    print("suggestWaterDate: $realDbw");
    //constrain within the limits imposed
    realDbw = max(realDbw, dbwLow.toDouble());

    realDbw = min(realDbw, dbwHigh.toDouble());
    print("suggestWaterDate: $realDbw");

    return safeDateTime(lastWatered.add(new Duration(days: realDbw.toInt())));
  }

//the following methods implement the dynamic plant functionality
//this returns the dynamicmultiplier should return 1.0 if invalid or not dynamic.
  double dynamicMultiplier() {
    //first check - is the plant dynamic to begin with?
    if (!isPlantDynamic) return 1.0;
    //second check - check for null or 0 in either field except for previous activity sum which is allowed to be 0
    if (lastActivitySampleCount == 0 ||
        lastActivitySampleCount == null ||
        currentActivitySampleCount == 0 ||
        currentActivitySampleCount == null ||
        currentActivitySum == 0 ||
        currentActivitySum == null ||
        lastActivitySum == null) return 1.0;
    //by the now we should have valid values for the SampleCounts and ActivitySums so do the
    //computation and return it

    return (lastActivitySum / lastActivitySampleCount) /
        (currentActivitySum / currentActivitySampleCount);
  }

  //returns true if the plant needs an update from the sample
  bool needsUpdate() {
    print('update check');
    if (!isPlantDynamic) return false;
    //calculate how many days since lastWatered and if it's higher than current sample count
    //then we need an update
    DateTime tempDate = DateTime.now().subtract(Duration(hours: 12));
    tempDate = DateTime(tempDate.year, tempDate.month, tempDate.day);
    int lastWateredDiff = min(tempDate.difference(lastWatered).inDays,
        nextWater.difference(lastWatered).inDays);
    print('lastwaterediff $lastWateredDiff');
    if (lastWateredDiff > currentActivitySampleCount) return true;
    //otherwise we don't
    return false;
  }

  bool isAvailable() {
    if (_holidayMode) return true;
    DateTime tempDate = DateTime.now().subtract(Duration(hours: 18));
    tempDate = DateTime(tempDate.year, tempDate.month, tempDate.day);
    if (tempDate.isSameOrAfter(nextWater)) return true;
    return false;
  }

  bool isLocked() {
    // return !waterMode;
    if (!isAvailable()) return true;
    if (needsUpdate()) return true;
    return false;
  }

  //update sample
  void updateSample(String sampleID, int sample) {
    DateTime tempDate;
    if (sampleID == this.sampleID && isPlantDynamic == true) {
      tempDate = DateTime.now().subtract(Duration(hours: 12));
      tempDate = DateTime(tempDate.year, tempDate.month, tempDate.day);
      currentActivitySampleCount = tempDate.difference(lastWatered).inDays;
      currentActivitySum += sample;

      //This code is intended for outdoor plants that might be subject to rainfall
      //if the sample is negative and makes the plants activity count reset to 0 or below
      //we should mark this plant as having been watered
      if (currentActivitySum <= 0) {
        //remember what the pastSampleCount is
        //
        double previousSum = lastActivitySum;
        int previousSampleCount = lastActivitySampleCount;
        currentActivitySum = 0;
        currentActivitySampleCount = 0;

        waterPlant();

        double sumCorrectionFactor = 1;
        if (dbw >= 1) sumCorrectionFactor = previousSampleCount / dbw;

        lastActivitySampleCount = dbw;
        lastActivitySum = sumCorrectionFactor * previousSum;
      }

      nextWater = suggestedWaterDate();
    }
  }

  void holidayMode(bool enableHolidayMode) {
    double tempMultiplier = multiplier;
    if (enableHolidayMode) {
      if (multiplier < 1.00) multiplier = 1.00;
      nextWater = suggestedWaterDate();
      multiplier = tempMultiplier;
      _holidayMode = true;
    } else {
      nextWater = suggestedWaterDate();
      _holidayMode = false;
    }
  }

//this is the method that converts the object into JSON for saveroutin
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
        'waterMode': waterMode,
        'isDelayed': isDelayed,
        'delayFactor': delayFactor,
        'isPlantDynamic': isPlantDynamic,
        'lastActivitySampleCount': lastActivitySampleCount,
        'lastActivitySum': lastActivitySum,
        'currentActivitySampleCount': currentActivitySampleCount,
        'currentActivitySum': currentActivitySum,
        'sampleID': sampleID,
        'loadBalancingOffset': loadBalancingOffset,
      };

//load balancing features

//this method returns the load balanced date by adding the loadBalancingoffset
//to the nextWater to find out when the scheduled date will be.abstract

  DateTime scheduledDate() {
    return nextWater.add(new Duration(days: loadBalancingOffset));
  }

//this method does 'online' load balancing i.e. it is intended to be run everytime
//a plant is scheduled it is not intended to be perfect but does the job it will pick
// the best slot between minOffset and maxOffset
  void onLineLoadBalancer(int minOffset, int maxOffset) {}
}

Future<void> insertPlant(Plant plant, Database database) async {
  // Get a reference to the database.
  final db = database;

  await db.insert(
    'plants',
    plant.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

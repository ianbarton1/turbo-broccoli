import 'dart:math';
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
  int checkStatus;
  int dbwLow;
  int dbwHigh;
  String homeZone;
  int loadBalancingOffset = 0;
  bool _holidayMode = false;
  List<Image> plantImage = [];
  List<DateTime> plantDateTime = [];
  Database database;
  dynamic tempImage;

  Plant(
      {this.uid = 1,
      this.name = '',
      this.previousWater,
      this.lastWatered,
      this.activeWatered,
      this.nextWater,
      this.dbw = 7,
      this.multiplier = 0.74,
      this.section,
      this.zone,
      this.checkStatus,
      this.homeZone,
      this.dbwLow = 1,
      this.dbwHigh = 100,
      this.waterMode = false,
      this.delayFactor = 2,
      this.isDelayed = false,
      this.currentActivitySampleCount = 0,
      this.currentActivitySum = 0,
      this.isPlantDynamic = false,
      this.lastActivitySampleCount = 0,
      this.lastActivitySum = 0,
      this.sampleID = '',
      this.loadBalancingOffset = 0,
      this.database}) {
    getDatabaseImage();
    if (previousWater == null || lastWatered == null || activeWatered == null) {
      this.previousWater =
          safeDateTime(DateTime.now().subtract(Duration(days: 7)));
      this.lastWatered =
          safeDateTime(DateTime.now().subtract(Duration(days: 0)));
      this.activeWatered = this.lastWatered;
    }
  }

//Gets databaseimages from the database and converts them to in-memory copies. Currently this will only get a maximum of 20 images
//FIXME: add offset such that the number of images held in memory can be kept to some constant whilst allowing more than 20 in memory.
  Future<void> getDatabaseImage() async {
    plantImage = [];
    plantDateTime = [];
    try {
      tempImage = await database.query("plant_images",
          columns: ["image", "date_time"],
          where: 'plantid = ?',
          whereArgs: [uid],
          limit: 20,
          orderBy: "date_time DESC");
    } catch (e) {
      debugPrint("Error retrieving image from database, $e");
      tempImage = [];
    }

    tempImage.forEach((e) {
      plantImage.add(new Image.memory(e['image']));
      if (e['date_time'] != null)
        plantDateTime.add(
            new DateTime.fromMillisecondsSinceEpoch((e['date_time'] * 1000)));
      else
        plantDateTime.add(null);
    });
  }

//Removes all pictures associated with a plant - useful for when the plant is to be removed and the images associated should be
//cleaned before the next plant
  Future<void> removeAllPictures() async {
    await database
        .delete("plant_images", where: "plantid = ?", whereArgs: [uid]);
  }

//Function that produces a 'Safe' DateTime i.e. it zeroes the time aspect of the DateTime class.
  DateTime safeDateTime(DateTime unsafeDateTime) {
    return DateTime(
        unsafeDateTime.year, unsafeDateTime.month, unsafeDateTime.day);
  }

//This function will return true if the selected plant's scheduled date is before the input date used to sort the collection
//
  bool filterDatesBetween(DateTime selectedDate) {
    if (!scheduledDate().isAfter(selectedDate)) return true;
    return false;
  }

  void setWateringDates() {
    previousWater = activeWatered;
    activeWatered = nextWater;
  }

//run a simulation and see whether this plant is going to be due to be checke on a specified date
  bool isFutureDate(DateTime queryDate) {
    queryDate = safeDateTime(queryDate);
    if (dbw <= 0) dbw = 1;

    //store the original multiplier such that it can be restored at the end of the sim.
    double originalMultiplier = multiplier;
    //stores the multiplier in the case that the current multiplier is greater than 1 so we can run the sim.
    double initialCorrectionToMultiplier = 1.00;

    double simulationMultiplier = 1.00;

    int waterCount = 0;
    //if the current date is equal to query date then who cares.
    if (suggestedWaterDate(normalCapRulesApplied: false).isSameDay(queryDate))
      return true;

    if (multiplier > 1.00) {
      initialCorrectionToMultiplier = multiplier;
      simulationMultiplier = 1.00;
      waterCount = 1;
    }
//run the simulation until the querydate is in the past.
    while (
        suggestedWaterDate(normalCapRulesApplied: false).isBefore(queryDate)) {
      // print("$uid ,$waterCount, $simulationMultiplier");
      if (waterCount % 2 == 0) {
        simulationMultiplier += 0.26;
      } else {
        simulationMultiplier += 0.74;
      }

      waterCount++;

      multiplier = simulationMultiplier * initialCorrectionToMultiplier;

      if (suggestedWaterDate(normalCapRulesApplied: false)
          .isSameDay(queryDate)) {
        multiplier = originalMultiplier;
        return true;
      }
    }
    multiplier = originalMultiplier;
    return false;
  }

//this method waters the plant and updates all the values to with that.
//FIXME: The logic in this function isn't exactly clear, too much is going on.
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
      multiplier = 0.74;

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
    if (dbw < 0) dbw = 1;

    //loop until the day has been incremented at least 1 day (better than the previous logic of adding a day!)

    while (nextWater.isSameDay(nextWaterBefore) ||
        nextWater.isBefore(nextWaterBefore)) {
      multiplier += 0.26;
      nextWater = suggestedWaterDate();
    }

    checkStatus = 0;
  }

//this small method returns the next suggested date to check a plant
  DateTime suggestedWaterDate({bool normalCapRulesApplied = true}) {
    double rawDynamicMultiplier = dynamicMultiplier();

    if (rawDynamicMultiplier < 0) rawDynamicMultiplier = 1.00;

    //calculate the ideal real dbw
    double realDbw =
        (dbw.toDouble() * multiplier * rawDynamicMultiplier).round().toDouble();

    // print("suggestWaterDate: $realDbw");
    //constrain within the limits imposed
    if (normalCapRulesApplied) {
      realDbw = max(realDbw, dbwLow.toDouble());
      realDbw = min(realDbw, dbwHigh.toDouble());
    } else {
      //FIXME: ignoring the normal cap rules for simulation purposes for now. should really get around to figuring out but who cares.
    }

    // print("suggestWaterDate: $realDbw");

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

    //final sanity check (do not allow negative dynamic multiplier)
    double potentialDynamicMultiplier =
        (lastActivitySum / lastActivitySampleCount) /
            (currentActivitySum / currentActivitySampleCount);

    if (potentialDynamicMultiplier < 0.00) {
      return 1.00;
    }

    return potentialDynamicMultiplier;
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

  void holidayMode(bool enableHolidayMode, DateTime holidayEndDate) {
    double tempMultiplier = multiplier;
    holidayEndDate = safeDateTime(holidayEndDate);
    if (enableHolidayMode) {
      if (multiplier < 1.00) multiplier = 1.00;
      nextWater = suggestedWaterDate();
      multiplier = tempMultiplier;

      if (nextWater > holidayEndDate ||
          safeDateTime(lastWatered) == safeDateTime(DateTime.now())) {
        // nextWater = suggestedWaterDate();
        _holidayMode = false;
      } else {
        _holidayMode = true;
      }
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

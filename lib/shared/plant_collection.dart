import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/zone_map.dart';

class PlantCollection {
  List<Plant> plantList = List();
  bool _holidayMode = false;

  PlantCollection();

  void saveToDatabase(Database database) async {
    // await database.delete('plants', where: null);
    plantList.forEach((element) async {
      await database.insert(
        'plants',
        element.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  void changeHolidayMode(bool enable) {
    plantList.forEach((element) {
      element.holidayMode(enable);
    });

    _holidayMode = enable;
  }

  void reindexZones(List<String> zoneList) {
    print('reindexing zones');
    plantList.forEach((element) {
      element.section = zoneList.indexOf(element.homeZone);
    });
  }

  void removePlant(int index, Database database) {
    int targetuid = plantList[index].uid;
    print("attempting to delete" + targetuid.toString());
    database.delete("plants", where: "uid = ?", whereArgs: [targetuid]);
    plantList.removeAt(index);
  }

  void orderCollection(bool sortbyid) {
    if (!sortbyid) {
      plantList.sort((a, b) {
        // int cmp1 = a.scheduledDate().compareTo(b.scheduledDate());
        int cmp1 = b
            .filterDatesBetween(DateTime.now().subtract(Duration(hours: 12)))
            .toString()
            .compareTo(a
                .filterDatesBetween(
                    DateTime.now().subtract(Duration(hours: 12)))
                .toString());
        if (cmp1 != 0) return cmp1;
        int cmp = a.section.compareTo(b.section);
        if (cmp != 0) return cmp;
        return a.uid.compareTo(b.uid);
      });
    } else {
      plantList.sort((a, b) {
        return a.uid.compareTo(b.uid);
      });
    }
  }

  int liveCount() {
    int result =
        dayCount(DateTime.now().add(Duration(days: _holidayMode ? 14 : 0)));
    print('liveCount= $result');
    return result;
  }

  int dayCount(DateTime selectedDate) {
    int result = 0;
    selectedDate = selectedDate.subtract(Duration(hours: 12));
    plantList.forEach((element) {
      if (!element.scheduledDate().isAfter(selectedDate)) result++;
    });
    print('dayCount= $result');
    return result;
  }

  DateTime safeDateTime(DateTime unsafeDateTime) {
    return DateTime(
        unsafeDateTime.year, unsafeDateTime.month, unsafeDateTime.day);
  }

  //add a new plant to the plantlist
  void addNew(Plant candidate) {
    plantList.add(candidate);
  }

  //check to see if an id exists in the list
  bool idCheck(int id) {
    for (int i = 0; i < plantList.length; i++) {
      if (plantList[i].uid == id) {
        return true;
      }
    }
    return false;
  }

  void actionChanges() {
    plantList.forEach((element) {
      switch (element.checkStatus) {
        case (1):
          {
            print('check plant');
            element.checkPlant();
          }
          break;
        case (2):
          {
            print('water plant');
            element.waterPlant();
          }
          break;
      }
    });
    orderCollection(true);
  }

  int freeID() {
    for (int i = 0; i < 200; i++) {
      if (!idCheck(i)) {
        return i;
      }
    }
    return -1;
  }

  List<Map<String, dynamic>> toJson() {
    return (plantList.map((e) => e.toJson())).toList();
  }
}

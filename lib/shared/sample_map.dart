import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/shared/sample.dart';

class SampleMap {
  List<Sample> samples = [];

  SampleMap();

  int getNextSampleID() {
    int returnID = -1;
    samples.forEach((element) {
      returnID = max(returnID, element.databaseID);
    });

    return returnID + 1;
  }

  //A sample needs attention!

  bool containsID(String sampleID) {
    samples.forEach((element) {
      if (element.sampleID == sampleID) return true;
    });

    return false;
  }

  bool needsUpdate() {
    bool updateState = false;
    samples.forEach((element) {
      if (element.needsUpdate()) updateState = true;
    });
    return updateState;
  }

  //add a new plant to the plantlist
  void addNew(Sample candidate) {
    samples.add(candidate);
  }

  List<Map<String, dynamic>> toJson() {
    return (samples.map((e) => e.toJson())).toList();
  }

  void saveToDatabase(Database database) {
    print("Save Samples Method Called");
    samples.forEach((element) async {
      await database.insert('samples', element.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  void removeSampleFromDatabase(Database database, int id) {
    try {
      int databaseid = samples[id].databaseID;
      print(samples.toString());
      database.delete("samples", where: "id = ?", whereArgs: [databaseid]);
      samples.removeAt(id);
    } catch (e) {
      print(e.toString());
      print("Error encountered when trying to remove sample with index $id");
    }
  }
}

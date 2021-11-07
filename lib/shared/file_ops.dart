import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'package:turbo_broccoli/shared/sample.dart';
import 'package:turbo_broccoli/shared/sample_map.dart';
import 'package:turbo_broccoli/shared/zone_map.dart';

//PlantCollection loadData;
void saveDisk(PlantCollection saveData, ZoneMap saveZone, SampleMap saveSamples,
    Database database) async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  plants.setString('plants', jsonEncode(saveData.toJson()));
  print('savedisk');
  print(jsonEncode(saveData.toJson()));
  saveData.saveToDatabase(database);

  plants.setString('zones', jsonEncode(saveZone.zoneList));
  print(jsonEncode(saveZone.zoneList));
  plants.setString('samples', jsonEncode(saveSamples.toJson()));
  print(jsonEncode(saveSamples.toJson()));
}

Future<List<dynamic>> loadDisk(Database database) async {
  SharedPreferences plants = await SharedPreferences.getInstance();

  final List<Map<String, dynamic>> plantmaps = await database.query('plants');
  print("plantsmaps");
  String plantObjects = jsonEncode(plantmaps);
  print("end of plantsmaps");

  //loadData = PlantCollection();
  List<dynamic> loadData;
  if (!plants.containsKey('plants')) {
    plants.setString('plants', '[]');
  }
  loadData = jsonDecode(plantObjects);

  return loadData;
}

Future<ZoneMap> loadZones() async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  //loadData = PlantCollection();
  List<String> loadData;
  ZoneMap loadedZoneMap;
  if (!plants.containsKey('zones')) {
    plants.setString('zones', '[]');
  }
  // loadData = jsonDecode(plants.get('zones'));
  loadData = (jsonDecode(plants.get('zones')) as List<dynamic>).cast<String>();
  loadedZoneMap = ZoneMap(zoneList: loadData);

  return loadedZoneMap;
}

//get sample data from disk (the raw data not in object form)
Future<List<dynamic>> loadSamples() async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  List<dynamic> loadData;
  if (!plants.containsKey('samples')) {
    plants.setString('samples', '[]');
  }
  // loadData = jsonDecode(plants.get('zones'));
  loadData = jsonDecode(plants.get('samples')) as List<dynamic>;

  return loadData;
}

SampleMap jsonToSampleMap(List<dynamic> temp) {
  SampleMap result = new SampleMap();
  temp.forEach((e) {
    result.addNew(new Sample(
      maxWeight: e['maxWeight'],
      lastChecked: DateTime.parse(e['lastChecked']),
      sampleID: e['sampleID'],
    ));
  });

  return result;
}

Future<SampleMap> sampleFromDisk() async {
  List<dynamic> temp = await loadSamples();
  return jsonToSampleMap(temp);
}

Future<PlantCollection> fromDisk(Database database) async {
  List<dynamic> temp = await loadDisk(database);
  return jsonToCollection(temp);
}

PlantCollection jsonToCollection(List<dynamic> temp) {
  PlantCollection result = new PlantCollection();
  temp.forEach((e) {
    result.addNew(new Plant(
      dbw: e['dbw'],
      uid: e['uid'],
      name: e['name'],
      previousWater: DateTime.parse(e['previousWater']),
      lastWatered: DateTime.parse(e['lastWatered']),
      nextWater: DateTime.parse(e['nextWater']),
      multiplier: e['multiplier'],
      checkStatus: e['checkStatus'],
      section: e['section'],
      zone: e['zone'],
      activeWatered: DateTime.parse(e['activeWatered']),
      homeZone: e['homeZone'],
      dbwHigh: e['dbwHigh'],
      dbwLow: e['dbwLow'],
      waterMode: (e['waterMode'].toString() == "true" || e['waterMode'] == 1)
          ? true
          : false,
      delayFactor: e['delayFactor'],
      isDelayed: (e['isDelayed'].toString() == "true" || e['isDelayed'] == 1)
          ? true
          : false,
      currentActivitySampleCount: e['currentActivitySampleCount'],
      currentActivitySum: e['currentActivitySum'],
      isPlantDynamic:
          (e['isPlantDynamic'].toString() == "true" || e['isPlantDynamic'] == 1)
              ? true
              : false,
      lastActivitySampleCount: e['lastActivitySampleCount'],
      lastActivitySum: e['lastActivitySum'],
      sampleID: e['sampleID'],
      loadBalancingOffset: e['loadBalancingOffset'],
    ));
  });

  return result;
}

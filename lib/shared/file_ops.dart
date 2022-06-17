import 'dart:convert';

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

  saveData.savePlantsToDatabase(database);

  plants.setString('zones', jsonEncode(saveZone.zoneList));
  print(jsonEncode(saveZone.zoneList));
  // plants.setString('samples', jsonEncode(saveSamples.toJson()));
  // print(jsonEncode(saveSamples.toJson()));

  saveSamples.saveToDatabase(database);
}

Future<List<dynamic>> loadPlants(Database database) async {
  final List<Map<String, dynamic>> plantmaps = await database.query('plants');
  print("plantsmaps");
  String plantObjects = jsonEncode(plantmaps);
  print("end of plantsmaps");

  List<dynamic> loadData;
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
Future<List<dynamic>> loadSamples(Database database) async {
  // SharedPreferences plants = await SharedPreferences.getInstance();
  final List<Map<String, dynamic>> sampleMaps = await database.query('samples');

  String sampleObjects = jsonEncode(sampleMaps);
  List<dynamic> loadData = jsonDecode(sampleObjects);

  return loadData;
}

SampleMap jsonToSampleMap(List<dynamic> temp) {
  SampleMap result = new SampleMap();
  temp.forEach((e) {
    result.addNew(new Sample(
      maxWeight: e['start_value'],
      lastChecked: DateTime.parse(e['last_checked']),
      sampleID: e['sample_name'],
    ));
  });

  return result;
}

Future<SampleMap> sampleFromDisk(Database database) async {
  List<dynamic> temp = await loadSamples(database);
  return jsonToSampleMap(temp);
}

Future<PlantCollection> fromDisk(Database database) async {
  List<dynamic> temp = await loadPlants(database);
  return jsonToCollection(temp, database);
}

PlantCollection jsonToCollection(List<dynamic> temp, Database database) {
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
        isPlantDynamic: (e['isPlantDynamic'].toString() == "true" ||
                e['isPlantDynamic'] == 1)
            ? true
            : false,
        lastActivitySampleCount: e['lastActivitySampleCount'],
        lastActivitySum: e['lastActivitySum'],
        sampleID: e['sampleID'],
        loadBalancingOffset: e['loadBalancingOffset'],
        database: database));
  });

  return result;
}

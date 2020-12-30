import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'package:turbo_broccoli/shared/sample.dart';
import 'package:turbo_broccoli/shared/sample_map.dart';
import 'package:turbo_broccoli/shared/zone_map.dart';

//PlantCollection loadData;
void saveDisk(
    PlantCollection saveData, ZoneMap saveZone, SampleMap saveSamples) async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  plants.setString('plants', jsonEncode(saveData.toJson()));
  print('savedisk');
  print(jsonEncode(saveData.toJson()));
  plants.setString('zones', jsonEncode(saveZone.zoneList));
  print(jsonEncode(saveZone.zoneList));
  plants.setString('samples', jsonEncode(saveSamples.toJson()));
  print(jsonEncode(saveSamples.toJson()));
}

Future<List<dynamic>> loadDisk() async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  //loadData = PlantCollection();
  List<dynamic> loadData;
  if (!plants.containsKey('plants')) {
    plants.setString('plants', '[]');
  }
  loadData = jsonDecode(plants.get('plants'));

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

Future<PlantCollection> fromDisk() async {
  List<dynamic> temp = await loadDisk();
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
      multiplier: e['multiplier'].toDouble(),
      checkStatus: e['checkStatus'],
      section: e['section'],
      zone: e['zone'],
      activeWatered: DateTime.parse(e['activeWatered']),
      homeZone: e['homeZone'],
      dbwHigh: e['dbwHigh'],
      dbwLow: e['dbwLow'],
      waterMode: e['waterMode'],
      delayFactor: e['delayFactor'].toDouble(),
      isDelayed: e['isDelayed'],
      currentActivitySampleCount: e['currentActivitySampleCount'],
      currentActivitySum: e['currentActivitySum'].toDouble(),
      isPlantDynamic: e['isPlantDynamic'],
      lastActivitySampleCount: e['lastActivitySampleCount'],
      lastActivitySum: e['lastActivitySum'].toDouble(),
      sampleID: e['sampleID'],
    ));
  });

  return result;
}

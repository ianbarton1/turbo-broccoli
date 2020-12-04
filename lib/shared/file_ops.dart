import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'package:turbo_broccoli/shared/zone_map.dart';

//PlantCollection loadData;
void saveDisk(PlantCollection saveData, ZoneMap saveZone) async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  plants.setString('plants', jsonEncode(saveData.toJson()));
  print('savedisk');
  print(jsonEncode(saveData.toJson()));
  plants.setString('zones', jsonEncode(saveZone.zoneList));
  print(jsonEncode(saveZone.zoneList));
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
      multiplier: e['multiplier'],
      checkStatus: e['checkStatus'],
      section: e['section'],
      zone: e['zone'],
      activeWatered: DateTime.parse(e['activeWatered']),
      homeZone: e['homeZone'],
      dbwHigh: e['dbwHigh'],
      dbwLow: e['dbwLow'],
    ));
  });

  return result;
}

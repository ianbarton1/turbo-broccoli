import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';

//PlantCollection loadData;
void saveDisk(PlantCollection saveData) async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  plants.setString('plants', jsonEncode(saveData.toJson()));
  print('savedisk');
  print(jsonEncode(saveData.toJson()));
}

// Future<PlantCollection> loadDisk() async {
//   SharedPreferences plants = await SharedPreferences.getInstance();
//   //loadData = PlantCollection();
//   loadData = plants.get('plants');
//   return loadData;
// }

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

Future<PlantCollection> fromDisk() async {
  List<dynamic> temp = await loadDisk();
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
    ));
  });

  return result;
}

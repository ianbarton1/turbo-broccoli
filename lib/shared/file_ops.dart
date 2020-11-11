import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
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
  loadData = jsonDecode(plants.get('plants'));
  return loadData;
}

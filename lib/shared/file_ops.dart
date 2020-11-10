import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';

PlantCollection loadData;
void saveDisk(PlantCollection saveData) async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  //plants.setString('plants', saveData;
}

Future<PlantCollection> loadDisk(String filePath) async {
  SharedPreferences plants = await SharedPreferences.getInstance();
  //loadData = PlantCollection();
  loadData = plants.get('plants');
  return loadData;
}

import 'dart:developer';

import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';

class PlantCollection {
  List<Plant> plantList = List();

  PlantCollection();
  //add a new plant to the plantlist
  void addNew(Plant candidate) {
    plantList.add(candidate);
  }

  //check to see if an id exists in the list
  bool idCheck(int id) {
    return false;
  }

  List<Map<String, dynamic>> toJson() {
    return (plantList.map((e) => e.toJson())).toList();
  }

  void fromDisk() async {
    List<dynamic> temp = await loadDisk();
    temp.forEach((e) {
      plantList.add(new Plant(
        dbw: e['dbw'],
        uid: e['uid'],
        name: e['name'],
        previousWater: DateTime.parse(e['previousWater']),
        lastWatered: DateTime.parse(e['lastWatered']),
        nextWater: DateTime.parse(e['nextWater']),
        multiplier: e['multiplier'],
      ));
    });
    print(temp.length);
    print(plantList.length);
    print(temp[0]['previousWater']);
    inspect(plantList[0]);
  }
}

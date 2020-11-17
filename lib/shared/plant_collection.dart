import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/zone_map.dart';

class PlantCollection {
  List<Plant> plantList = List();

  PlantCollection();

  void reindexZones(List<String> zoneList) {
    print('reindexing zones');
    plantList.forEach((element) {
      element.section = zoneList.indexOf(element.homeZone);
    });
  }

  void orderCollection() {
    plantList.sort((a, b) {
      int cmp1 = a.nextWater.compareTo(b.nextWater);
      if (cmp1 != 0) return cmp1;
      int cmp = a.section.compareTo(b.section);
      if (cmp != 0) return cmp;
      return a.uid.compareTo(b.uid);
    });
  }

  int liveCount() {
    int result = 0;
    plantList.forEach((element) {
      if (!element.nextWater.isAfter(DateTime.now())) result++;
    });
    print('liveCount= $result');
    return result;
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
    orderCollection();
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

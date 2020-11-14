import 'package:turbo_broccoli/shared/plant.dart';

class PlantCollection {
  List<Plant> plantList = List();

  PlantCollection();

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
    return false;
  }

  List<Map<String, dynamic>> toJson() {
    return (plantList.map((e) => e.toJson())).toList();
  }
}

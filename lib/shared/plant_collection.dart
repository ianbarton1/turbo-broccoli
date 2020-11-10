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
}

class Plant {
  int uid;
  String name;
  DateTime previousWater;
  DateTime lastWatered;
  DateTime nextWater;
  int dbw;
  double multiplier;

  Plant(
      {this.uid,
      this.name,
      this.previousWater,
      this.lastWatered,
      this.nextWater,
      this.dbw,
      this.multiplier});

  void waterPlant() {
    previousWater = lastWatered;
    lastWatered = DateTime.now();
    dbw = lastWatered.difference(previousWater).inDays;
    multiplier = 0.75;
    nextWater = suggestedWaterDate();
  }

  void checkPlant() {
    multiplier += 0.25;
  }

  DateTime suggestedWaterDate() {
    return lastWatered
        .add(new Duration(days: (dbw.toDouble() * multiplier).round()));
  }
}

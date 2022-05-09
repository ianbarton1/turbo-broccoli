import 'package:turbo_broccoli/shared/zone.dart';

class ZoneMap {
  List<String> zoneList = [];
  // List<Zone> zoneList = List();

  ZoneMap({this.zoneList}) {
    if (this.zoneList.length == null) this.zoneList.length = 0;
  }
}

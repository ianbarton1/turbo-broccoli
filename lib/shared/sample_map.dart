import 'package:turbo_broccoli/shared/sample.dart';

class SampleMap {
  List<Sample> samples = [];

  SampleMap();

  //A sample needs attention!

  bool containsID(String sampleID) {
    samples.forEach((element) {
      if (element.sampleID == sampleID) return true;
    });

    return false;
  }

  bool needsUpdate() {
    bool updateState = false;
    samples.forEach((element) {
      if (element.needsUpdate()) updateState = true;
    });
    return updateState;
  }

  //add a new plant to the plantlist
  void addNew(Sample candidate) {
    samples.add(candidate);
  }

  List<Map<String, dynamic>> toJson() {
    return (samples.map((e) => e.toJson())).toList();
  }
}

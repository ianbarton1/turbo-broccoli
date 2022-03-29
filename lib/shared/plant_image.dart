import 'package:flutter/material.dart';

class PlantImage {
  Image plantImage;
  DateTime plantdatetime = new DateTime(2000, 01, 01);
  bool hasDateTime;
  bool hasPlantImage;
  PlantImage({this.plantImage, this.plantdatetime});
}

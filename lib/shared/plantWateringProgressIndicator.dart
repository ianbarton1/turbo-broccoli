import 'package:flutter/material.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';

class PlantStatusPainter extends CustomPainter with ChangeNotifier {
  PlantCollection plantCollection;
  int currentIndex;

  PlantStatusPainter({this.plantCollection, this.currentIndex});

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    int itemsInRow = 14;
    int totalRows = (plantCollection.liveCount() / itemsInRow).ceil();
    for (int i = 0; i < plantCollection.liveCount(); i++) {
      debugPrint(plantCollection.plantList[i].checkStatus.toString());

      switch (plantCollection.plantList[i].checkStatus) {
        case 1:
          paint..color = Colors.redAccent;
          break;
        case 2:
          paint..color = Colors.blueAccent;
          break;
        default:
          paint..color = Colors.black;
      }

      canvas.drawCircle(
          Offset(size.width / itemsInRow * (i % itemsInRow + 0.5),
              size.height / totalRows * ((i / itemsInRow).floor() + 0.5)),
          10,
          paint);

      if (i == currentIndex) {
        canvas.drawCircle(
            Offset(size.width / itemsInRow * (i % itemsInRow + 0.5),
                size.height / totalRows * ((i / itemsInRow).floor() + 0.5)),
            10,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.00
              ..color = Colors.amber);
      }
    }
  }

  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

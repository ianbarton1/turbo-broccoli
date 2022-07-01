import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:turbo_broccoli/main.dart';

class ActivityPreviewer extends StatefulWidget {
  const ActivityPreviewer({Key key}) : super(key: key);

  @override
  State<ActivityPreviewer> createState() => _ActivityPreviewerState();
}

class _ActivityPreviewerState extends State<ActivityPreviewer> {
  List<Text> dayPreviewTest = [];
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 7; i++) {
      dayPreviewTest.add(Text(
          "${DateTime.now().add(Duration(days: i))} = ${plantList.activityOnDay(DateTime.now().add(Duration(days: i))).toString()}"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Activity Preview")),
      body: Container(
        child: Column(
          children: [Text(plantList.plantList[51].name), ...dayPreviewTest],
        ),
      ),
    );
  }
}

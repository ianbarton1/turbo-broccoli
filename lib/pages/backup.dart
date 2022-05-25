import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';

class BackupManager extends StatefulWidget {
  final Function() notifyParent;
  final Database database;

  BackupManager(this.database, {this.notifyParent});

  @override
  _BackupManagerState createState() => _BackupManagerState();
}

class _BackupManagerState extends State<BackupManager> {
  TextEditingController plantsBackup;
  String backupMode = 'Plants';
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    plantsBackup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String backupData;
    switch (backupMode) {
      case ('Plants'):
        backupData = jsonEncode(plantList.toJson());
        break;
      case ('Zones'):
        backupData = jsonEncode(zoneList.zoneList);
        break;
      case ('Samples'):
        backupData = jsonEncode(sampleList.toJson());
        break;
    }

    List<dynamic> tempData;
    plantsBackup = TextEditingController(text: backupData);
    return Scaffold(
        appBar: AppBar(
          title: Text('Backup/Restore'),
          actions: [
            Builder(builder: (BuildContext context) {
              return TextButton(
                  onPressed: () {
                    setState(() {
                      widget.notifyParent();
                      tempData = jsonDecode(plantsBackup.text);
                      switch (backupMode) {
                        case ('Plants'):
                          plantList =
                              jsonToCollection(tempData, widget.database);
                          break;
                        case ('Zones'):
                          zoneList.zoneList = tempData.cast<String>().toList();
                          break;
                        case ('Samples'):
                          sampleList = jsonToSampleMap(tempData);
                          break;
                      }

                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Restored Data')));
                    });
                  },
                  child: FaIcon(FontAwesomeIcons.arrowsRotate));
            })
          ],
        ),
        body: Center(
          child: Column(
            children: [
              DropdownButton<String>(
                  value: backupMode,
                  items: [
                    DropdownMenuItem(value: 'Plants', child: Text('Plants')),
                    DropdownMenuItem(value: 'Zones', child: Text('Zones')),
                    DropdownMenuItem(value: 'Samples', child: Text('Samples'))
                  ],
                  onChanged: (value) {
                    setState(() {
                      backupMode = value ?? 'null';
                    });
                  }),
              Expanded(
                  child: Container(
                      child: TextFormField(
                controller: plantsBackup,
                maxLines: 30,
              ))),
            ],
          ),
        ));
  }
}

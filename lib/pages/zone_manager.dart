import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';

class ZoneManager extends StatefulWidget {
  @override
  _ZoneManagerState createState() => _ZoneManagerState();
}

class _ZoneManagerState extends State<ZoneManager> {
  TextEditingController newZoneName = TextEditingController();

  _displayDialog() {
    newZoneName.clear();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            elevation: 6,
            backgroundColor: Colors.transparent,
            child: _DialogWithTextField(context),
          );
        });
  }

  Widget _DialogWithTextField(BuildContext context) => Container(
        height: 210,
        decoration: BoxDecoration(
          color: Colors.green[900],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              "Add New Zone",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 10),
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                child: TextFormField(
                  controller: newZoneName,
                  maxLines: 1,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Zone Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                RaisedButton(
                  color: Colors.white,
                  child: Text(
                    "Save".toUpperCase(),
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      zoneList.zoneList.add(newZoneName.text);
                    });
                    return Navigator.of(context).pop(true);
                  },
                )
              ],
            ),
          ],
        ),
      );

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    newZoneName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Zone Manager'),
          actions: [
            FlatButton(
                onPressed: () {
                  _displayDialog();
                },
                child: FaIcon(FontAwesomeIcons.plus))
          ],
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ReorderableListView(
              children: getListItems(),
              onReorder: onReorder,
            ),
          ),
        ));
  }

  List<ListTile> getListItems() => zoneList.zoneList
      .asMap()
      .map((i, item) => MapEntry(i, buildTenableListTile(item, i)))
      .values
      .toList();

  ListTile buildTenableListTile(String item, int index) {
    return ListTile(
      contentPadding: EdgeInsets.all(10),
      tileColor: Colors.green[900],
      selectedTileColor: Colors.red,
      key: ValueKey(item),
      title: Row(
        children: [
          FaIcon(FontAwesomeIcons.gripVertical),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Text(item),
          )),
          FlatButton(
              height: 50,
              minWidth: 50,
              // color: Colors.black,
              // shape: ,
              child: FaIcon(FontAwesomeIcons.trash),
              onPressed: () {
                setState(() {
                  zoneList.zoneList.removeAt(index);
                });
              }),
        ],
      ),
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      String i = zoneList.zoneList[oldIndex];

      zoneList.zoneList.removeAt(oldIndex);
      zoneList.zoneList.insert(newIndex, i);

      plantList.reindexZones(zoneList.zoneList);
    });
  }
}

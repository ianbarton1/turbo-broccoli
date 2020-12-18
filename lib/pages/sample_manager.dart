import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/sample.dart';

class SampleManager extends StatefulWidget {
  final Function() notifyParent;

  SampleManager({this.notifyParent});
  @override
  _SampleManagerState createState() => _SampleManagerState();
}

class _SampleManagerState extends State<SampleManager> {
  TextEditingController newSampleName = TextEditingController();
  TextEditingController newSampleMaxWeight = TextEditingController();

  _displayDialog() {
    newSampleName.clear();
    newSampleMaxWeight.clear();
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
        height: 310,
        decoration: BoxDecoration(
          color: Colors.green[900],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              "Add New Sample",
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
                  controller: newSampleName,
                  maxLines: 1,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Sample Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                )),
            SizedBox(height: 10),
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                child: TextFormField(
                  controller: newSampleMaxWeight,
                  maxLines: 1,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Starting Weight for Sample',
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
                      sampleList.addNew(new Sample(
                        sampleID: newSampleName.text,
                        maxWeight: int.parse(newSampleMaxWeight.text),
                        lastChecked: DateTime.now().subtract(Duration(days: 1)),
                      ));
                      widget.notifyParent();
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
    newSampleName.dispose();
    newSampleMaxWeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sample Manager'),
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

  List<ListTile> getListItems() => sampleList.samples
      .asMap()
      .map((i, item) => MapEntry(i, buildTenableListTile(item.sampleID, i)))
      .values
      .toList();

  ListTile buildTenableListTile(String item, int index) {
    return ListTile(
      contentPadding: EdgeInsets.all(10),
      tileColor: Colors.green[900],
      selectedTileColor: Colors.red,
      key: ValueKey('sample $item $index'),
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
              child: FaIcon(FontAwesomeIcons.trash),
              onPressed: () {
                setState(() {
                  sampleList.samples.removeAt(index);
                  widget.notifyParent();
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
      Sample i = sampleList.samples[oldIndex];

      sampleList.samples.removeAt(oldIndex);
      sampleList.samples.insert(newIndex, i);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/sample.dart';

class SampleManager extends StatefulWidget {
  final Function() notifyParent;
  final Database database;

  SampleManager({this.notifyParent, this.database});
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
            child: _dialogWithTextField(context),
          );
        });
  }

  Widget _dialogWithTextField(BuildContext context) => Container(
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
                TextButton(
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
                TextButton(
                  child: Text(
                    "Save".toUpperCase(),
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      sampleList.addNew(new Sample(
                        sampleList.getNextSampleID(),
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
            TextButton(
                onPressed: () {
                  _displayDialog();
                },
                child: FaIcon(FontAwesomeIcons.plus)),
            TextButton(
                onPressed: null,
                onLongPress: () {
                  while (sampleList.samples.isNotEmpty) {
                    sampleList.removeSampleFromDatabase(
                        widget.database, sampleList.samples.length - 1);
                  }
                },
                child: FaIcon(FontAwesomeIcons.trash))
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
      .map((i, item) => MapEntry(i, buildTenableListTile(item, i)))
      .values
      .toList();

  ListTile buildTenableListTile(Sample item, int index) {
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
            child: Text("${item.sampleID} ${item.databaseID.toString()}"),
          )),
          TextButton(
              child: FaIcon(FontAwesomeIcons.trash),
              onPressed: () {
                setState(() {
                  sampleList.removeSampleFromDatabase(widget.database, index);
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

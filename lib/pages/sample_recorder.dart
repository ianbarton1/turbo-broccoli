import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/sample.dart';

class SampleRecorder extends StatefulWidget {
  final Function() notifyParent;

  SampleRecorder({this.notifyParent});

  @override
  _SampleRecorderState createState() => _SampleRecorderState();
}

class _SampleRecorderState extends State<SampleRecorder> {
  TextEditingController newSampleMaxWeight = TextEditingController();
  Sample selectedSample;

  _displayDialog() {
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
        height: 200,
        decoration: BoxDecoration(
          color: Colors.green[900],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 24),
            Text(
              "${selectedSample.sampleID}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
                child: TextFormField(
                  controller: newSampleMaxWeight,
                  maxLines: 1,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Sample Metric',
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
                ElevatedButton(
                  child: Text(
                    "Save".toUpperCase(),
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      //we are going to first update the sample's internal date
                      selectedSample.updateSample(
                          int.parse(newSampleMaxWeight.text), plantList);
                      widget.notifyParent();
                      Phoenix.rebirth(context);
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
    newSampleMaxWeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // widget.notifyParent();
    return Scaffold(
        appBar: AppBar(
          title: Text('Sample Recorder'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ListView(
              children: getListItems(),
            ),
          ),
        ));
  }

  List<Padding> getListItems() => sampleList.samples
      .asMap()
      .map((i, item) =>
          MapEntry(i, buildTenableListTile(item.sampleID, i, item)))
      .values
      .toList();

  Padding buildTenableListTile(String item, int index, Sample sampleObj) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        tileColor:
            sampleObj.needsUpdate() ? Colors.red[400] : Colors.green[900],
        selectedTileColor: Colors.red,
        key: ValueKey('sample $item $index'),
        title: Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${sampleObj.sampleID}'),
                      Text('${sampleObj.maxWeight} - ${sampleObj.lastChecked}')
                    ]),
              ),
              sampleObj.needsUpdate()
                  ? TextButton(
                      child: FaIcon(FontAwesomeIcons.plus),
                      onPressed: () {
                        setState(() {
                          selectedSample = sampleObj;
                          _displayDialog();
                        });
                      })
                  : Container(),
            ],
          ),
        ),
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

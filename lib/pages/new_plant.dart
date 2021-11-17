import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/sample.dart';

class NewPlant extends StatefulWidget {
  bool editMode = false;
  Plant plant;
  final Function() notifyParent;
  Database database;
  NewPlant({this.plant, this.notifyParent, this.database}) {
    if (plant != null) editMode = true;
  }

  @override
  _NewPlantState createState() => _NewPlantState(editMode, plant);
}

class _NewPlantState extends State<NewPlant> {
  bool editMode;

  bool uidCheck = true;
  Plant tempPlant;
  _NewPlantState(this.editMode, this.tempPlant) {
    // if (widget.plant != null) tempPlant = widget.plant;
    // create some filler items if the zoneList or sampleList is empty
    if (zoneList.zoneList.isEmpty) zoneList.zoneList.add('No Zone');
    if (sampleList.samples.isEmpty) {
      sampleList.addNew(Sample(
          sampleID: 'No Sample', maxWeight: 0, lastChecked: DateTime.now()));
      sampleSelect = 'No Sample';
    }
    //
    if (editMode == true) {
      uidController.text = tempPlant.uid.toString();
      nameController.text = tempPlant.name;
      lastWateredPicker = tempPlant.lastWatered;
      previousWateredPicker = tempPlant.previousWater;
      _rangeValues = RangeValues(
          tempPlant.dbwLow.toDouble(), tempPlant.dbwHigh.toDouble());
      newHomeZone = tempPlant.homeZone;
      sampleSelect = tempPlant.sampleID;
      if (!zoneList.zoneList.contains(tempPlant.homeZone))
        zoneList.zoneList.add(tempPlant.homeZone);
      if (!sampleList.containsID(sampleSelect)) {
        sampleSelect = sampleList.samples.first.sampleID;
      }
      isPlantDynamic = tempPlant.isPlantDynamic;
      isPlantDelayed = tempPlant.isDelayed;
      waterMode = tempPlant.waterMode;
    } else {
      uidController.text = plantList.freeID().toString();
      newHomeZone = zoneList.zoneList.first;
      sampleSelect = sampleList.samples.first.sampleID;
      lastWateredPicker = DateTime(lastWateredPicker.year,
          lastWateredPicker.month, lastWateredPicker.day);
      previousWateredPicker = lastWateredPicker.subtract(Duration(days: 7));
    }
  }

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final uidController = TextEditingController();
  final sectionController = TextEditingController(text: '0');
  final zoneController = TextEditingController(text: '0');
  final dbwLowController = TextEditingController(text: '0');
  final dbwHighController = TextEditingController(text: '365');
  String newHomeZone;
  String sampleSelect;
  RangeValues _rangeValues = new RangeValues(1, 100);
  bool isPlantDynamic = false;

  bool isPlantDelayed = false;
  bool waterMode = false;

  DateTime temp;
  DateTime lastWateredPicker = DateTime.now();
  DateTime previousWateredPicker;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    uidController.dispose();
    sectionController.dispose();
    zoneController.dispose();
    dbwHighController.dispose();
    dbwLowController.dispose();
    super.dispose();
    print("New Plant (Exit) = ${widget.database}");
  }

  @override
  void initState() {
    super.initState();
    print("New Plant = ${widget.database}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: widget.editMode ? Text('Edit Plant ') : Text('Add New Plant'),
        // actions: [FlatButton(onPressed: () {}, child: Text('Save'))],
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        helperText: 'An unique identifier (auto-populated)',
                        labelText: 'UID',
                        suffix: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: uidCheck
                              ? FaIcon(FontAwesomeIcons.check,
                                  size: 20, color: Colors.green)
                              : FaIcon(
                                  FontAwesomeIcons.exclamationTriangle,
                                  size: 20,
                                  color: Colors.red,
                                ),
                        )),
                    validator: (value) {
                      if (value.isEmpty) return 'Enter an UID';
                      if ((plantList.idCheck(int.parse(value)) &&
                              editMode == false) ||
                          (int.parse(value) !=
                                  (tempPlant == null ? -1 : tempPlant.uid) &&
                              plantList.idCheck(int.parse(value))))
                        return 'This UID is already in use.';

                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        uidCheck = !plantList.idCheck(int.parse(value));
                        if (editMode && tempPlant.uid == int.parse(value))
                          uidCheck = true;
                      });
                    },
                    controller: uidController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        helperText: 'A quick description of the plant',
                        labelText: 'Name'),
                    validator: (value) {
                      if (value.isEmpty) return 'Enter a name';
                      return null;
                    },
                    controller: nameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Last Watered: ${DateFormat('yyyy-MM-dd').format(lastWateredPicker)}',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2001),
                                  lastDate: DateTime(2025))
                              .then((date) {
                            setState(() {
                              if (date != null) lastWateredPicker = date;
                            });
                          });
                        },
                        child: Icon(Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Previously Watered: ${DateFormat('yyyy-MM-dd').format(previousWateredPicker)}',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2001),
                                  lastDate: DateTime(2025))
                              .then((date) {
                            setState(() {
                              if (date != null) previousWateredPicker = date;
                            });
                          });
                        },
                        child: Icon(Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                        'Home Zone:',
                        style: TextStyle(fontSize: 18),
                      )),
                      DropdownButton<String>(
                        value: newHomeZone,
                        items: zoneList.zoneList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            newHomeZone = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Acceptable Water Cycle Duration',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${_rangeValues.start.round().toString()} to ${_rangeValues.end.round().toString()} days',
                          style: TextStyle(
                              fontSize: 17, fontStyle: FontStyle.italic),
                        ),
                        RangeSlider(
                          values: _rangeValues,
                          min: 1,
                          max: 100,
                          divisions: 20,
                          labels: RangeLabels(
                              _rangeValues.start.round().toString(),
                              _rangeValues.end.round().toString()),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _rangeValues = values;
                            });
                          },
                        ),
                      ],
                    )),
                // TextFormField(
                //   keyboardType: TextInputType.number,
                //   decoration: InputDecoration(
                //       helperText:
                //           'A zone number helps to plan your watering walk.',
                //       labelText: 'Routing Zone Number'),
                //   validator: (value) {
                //     if (value.isEmpty) return 'Enter a zone number';
                //     return null;
                //   },
                //   controller: zoneController,
                // ),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                            activeColor: Colors.blue,
                            checkColor: Colors.black,
                            value: isPlantDynamic,
                            onChanged: (value) {
                              setState(() {
                                isPlantDynamic ^= true;
                              });
                            }),
                        Text('Make Plant Dynamic')
                      ],
                    ),
                    Row(
                      children: [
                        isPlantDynamic
                            ? Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text('Sample Subscription'),
                                  ),
                                  DropdownButton<String>(
                                    value: sampleSelect,
                                    items:
                                        sampleList.samples.map((Sample value) {
                                      return new DropdownMenuItem<String>(
                                        value: value.sampleID,
                                        child: new Text(value.sampleID),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        sampleSelect = newValue;
                                        print(sampleSelect);
                                      });
                                    },
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
                // These boxes were a hacky way io be able to modify some functionlity that I've decided I'm probably not even going to use
                // Column(
                //   children: [
                //     Checkbox(
                //         value: isPlantDelayed,
                //         onChanged: (value) {
                //           setState(() {
                //             isPlantDelayed ^= true;
                //           });
                //         }),
                //     Checkbox(
                //         value: waterMode,
                //         onChanged: (value) {
                //           setState(() {
                //             waterMode ^= true;
                //           });
                //         }),
                //   ],
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          if (editMode != true) {
                            plantList.addNew(new Plant(
                                uid: int.parse(uidController.text),
                                name: nameController.text,
                                previousWater: previousWateredPicker,
                                lastWatered: lastWateredPicker,
                                activeWatered: lastWateredPicker,
                                dbw: lastWateredPicker
                                    .difference(previousWateredPicker)
                                    .inDays,
                                multiplier: 0.75,
                                section: 0,
                                zone: 0,
                                nextWater: DateTime(2020, 11, 15),
                                checkStatus: 0,
                                homeZone: newHomeZone,
                                dbwLow: _rangeValues.start.round(),
                                dbwHigh: _rangeValues.end.round(),
                                waterMode: waterMode,
                                isDelayed: isPlantDelayed,
                                delayFactor: 2,
                                isPlantDynamic: isPlantDynamic,
                                currentActivitySampleCount: 0,
                                currentActivitySum: 0,
                                lastActivitySampleCount: 0,
                                lastActivitySum: 0,
                                sampleID: sampleSelect,
                                database: widget.database));
                          } else {
                            print('edit mode');
                            tempPlant.name = nameController.text;
                            tempPlant.uid = int.parse(uidController.text);
                            tempPlant.previousWater = previousWateredPicker;
                            tempPlant.lastWatered = lastWateredPicker;
                            tempPlant.dbwLow = _rangeValues.start.round();
                            tempPlant.dbwHigh = _rangeValues.end.round();
                            tempPlant.homeZone = newHomeZone;
                            tempPlant.isPlantDynamic = isPlantDynamic;
                            tempPlant.sampleID = sampleSelect;
                            tempPlant.isDelayed = isPlantDelayed;
                            tempPlant.waterMode = waterMode;
                            tempPlant.nextWater =
                                tempPlant.suggestedWaterDate();

                            tempPlant.database = widget.database;
                          }
                          //common to both edit and new plant
                          plantList.plantList[plantList.plantList.length - 1]
                                  .nextWater =
                              plantList
                                  .plantList[plantList.plantList.length - 1]
                                  .suggestedWaterDate();
                          plantList.reindexZones(zoneList.zoneList);
                          saveDisk(
                              plantList, zoneList, sampleList, widget.database);

                          if (editMode == true) {
                            widget.notifyParent();
                            Navigator.pop(context);
                          } else {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Phoenix.rebirth(context);
                          }
                        }
                      },
                      child:
                          editMode ? Text('Save Changes') : Text('Add Plant')),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';

class NewPlant extends StatefulWidget {
  @override
  _NewPlantState createState() => _NewPlantState();
}

class _NewPlantState extends State<NewPlant> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final uidController =
      TextEditingController(text: plantList.freeID().toString());
  final sectionController = TextEditingController(text: '0');
  final zoneController = TextEditingController(text: '0');
  String newHomeZone;

  DateTime temp;
  DateTime lastWateredPicker = DateTime.now();
  DateTime previousWateredPicker = DateTime.now().subtract(Duration(days: 7));

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    uidController.dispose();
    sectionController.dispose();
    zoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Add New Plant'),
        // actions: [FlatButton(onPressed: () {}, child: Text('Save'))],
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      helperText: 'An unique identifier (auto-populated)',
                      labelText: 'UID'),
                  validator: (value) {
                    if (value.isEmpty) return 'Enter an UID';
                    return null;
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
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
                        ));
                        plantList.plantList[plantList.plantList.length - 1]
                                .nextWater =
                            plantList.plantList[plantList.plantList.length - 1]
                                .suggestedWaterDate();
                        plantList.reindexZones(zoneList.zoneList);
                        saveDisk(plantList, zoneList);
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Text('Add Plant')),
              )
            ],
          ),
        ),
      )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Plant'),
        // actions: [FlatButton(onPressed: () {}, child: Text('Save'))],
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
              TextFormField(
                decoration: InputDecoration(
                    helperText: 'A quick description of the plant',
                    labelText: 'Name'),
                validator: (value) {
                  if (value.isEmpty) return 'Enter a name';
                  return null;
                },
                controller: nameController,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      plantList.addNew(new Plant(
                        uid: int.parse(uidController.text),
                        name: nameController.text,
                        previousWater:
                            DateTime.now().subtract(new Duration(days: 7)),
                        lastWatered: DateTime.now(),
                        dbw: 7,
                        multiplier: 0.75,
                        section: rng.nextInt(7),
                        nextWater: DateTime(2020, 11, 15),
                        checkStatus: 0,
                      ));
                      plantList.plantList[plantList.plantList.length - 1]
                              .nextWater =
                          plantList.plantList[plantList.plantList.length - 1]
                              .suggestedWaterDate();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: Text('Add Plant'))
            ],
          ),
        ),
      )),
    );
  }
}

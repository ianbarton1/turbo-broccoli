import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:turbo_broccoli/pages/new_plant.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:flutter/material.dart';

class PlantInfo extends StatelessWidget {
  final Plant plant;
  PlantInfo({this.plant}) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${plant.uid} - ${plant.name}'),
          actions: [
            IconButton(
                icon: FaIcon(FontAwesomeIcons.edit),
                onPressed: () {
                  print('im doing something');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewPlant(plant: plant)));
                }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                'Name: ${plant.name}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Location (Home Zone): ${plant.homeZone}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Cycle Length (Days Between Watering): ${plant.dbw}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Minimum Cycle Length: ${plant.dbwLow}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Maximum Cycle Length: ${plant.dbwHigh}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Previously Watered on: ${DateFormat('yyyy-MM-dd').format(plant.previousWater)}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Last Watered on: ${DateFormat('yyyy-MM-dd').format(plant.lastWatered)}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Current Multiplier: ${plant.multiplier}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Next Check on: ${DateFormat('yyyy-MM-dd').format(plant.nextWater)}',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ));
  }
}

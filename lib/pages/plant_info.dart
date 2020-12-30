import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:turbo_broccoli/pages/new_plant.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:flutter/material.dart';

class PlantInfo extends StatefulWidget {
  final Plant plant;
  PlantInfo({this.plant});

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.plant.uid} - ${widget.plant.name}'),
          actions: [
            IconButton(
                icon: FaIcon(FontAwesomeIcons.edit),
                onPressed: () {
                  print('im doing something');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewPlant(
                                plant: widget.plant,
                                notifyParent: () {
                                  setState(() {});
                                },
                              )));
                }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                'Name: ${widget.plant.name}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Location (Home Zone): ${widget.plant.homeZone}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Cycle Length (Days Between Watering): ${widget.plant.dbw}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Minimum Cycle Length: ${widget.plant.dbwLow}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Maximum Cycle Length: ${widget.plant.dbwHigh}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Previously Watered on: ${DateFormat('yyyy-MM-dd').format(widget.plant.previousWater)}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Last Watered on: ${DateFormat('yyyy-MM-dd').format(widget.plant.lastWatered)}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Current Multiplier: ${widget.plant.multiplier}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Next Check on: ${DateFormat('yyyy-MM-dd').format(widget.plant.nextWater)}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Is Delayed Plant: ${widget.plant.isDelayed}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Current Check Mode: ${widget.plant.waterMode}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Is this plant Dynamic? ${widget.plant.isPlantDynamic}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Last Cycle Activity Total ${widget.plant.lastActivitySum}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Last Cycle Activity Sample ${widget.plant.lastActivitySampleCount}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Last Cycle Activity Total ${widget.plant.currentActivitySum}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Last Cycle Activity Sample ${widget.plant.currentActivitySampleCount}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Dynamic Multiplier ${widget.plant.dynamicMultiplier()}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'NeedsUpdate? ${widget.plant.needsUpdate()}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Dynamically Calculated Date? ${widget.plant.suggestedWaterDate()}',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'SampleID? ${widget.plant.sampleID}',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ));
  }
}

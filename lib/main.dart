import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_broccoli/pages/backup.dart';
import 'package:turbo_broccoli/pages/new_plant.dart';
import 'package:turbo_broccoli/pages/sample_manager.dart';
import 'package:turbo_broccoli/pages/sample_recorder.dart';
import 'package:turbo_broccoli/pages/zone_manager.dart';
import 'package:turbo_broccoli/shared/card.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'package:turbo_broccoli/shared/sample.dart';
import 'package:turbo_broccoli/shared/sample_map.dart';
import 'package:turbo_broccoli/shared/zone.dart';
import 'dart:developer';

import 'package:turbo_broccoli/shared/zone_map.dart';

PlantCollection plantList;
ZoneMap zoneList;
SampleMap sampleList;
Random rng = new Random();
bool _showAll = false;
bool _allowDelete = false;

void main() {
  runApp(Home(
    title: 'Turbo Broccoli',
  ));
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();

  Widget build(BuildContext context) {
    plantList.orderCollection();
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Home(title: 'Turbo Broccoli'),
      },
    );
  }
}

class _HomeState extends State<Home> {
  void populateList() async {
    // SharedPreferences debug = await SharedPreferences.getInstance();
    // await debug.clear();
    plantList = await fromDisk();
    zoneList = await loadZones();
    sampleList = await sampleFromDisk();
    if (plantList == null) plantList = new PlantCollection();
    if (zoneList == null) zoneList = new ZoneMap();
    if (sampleList == null) sampleList = new SampleMap();
    setState(() {});
  }

  int liveCount = 0;

  @override
  void initState() {
    super.initState();
    if (plantList == null) populateList();
  }

  @override
  Widget build(BuildContext context) {
    if (plantList != null) {
      plantList.orderCollection();
      liveCount = _showAll ? plantList.plantList.length : plantList.liveCount();
    }

    return MaterialApp(
      routes: {
        '/home': (context) => Home(
              title: 'Turbo Broccoli',
            ),
        '/add_new': (context) => NewPlant(),
        '/zone_manager': (context) => ZoneManager(
              notifyParent: () {
                setState(() {});
              },
            ),
        '/sample_manager': (context) => SampleManager(
              notifyParent: () {
                setState(() {});
              },
            ),
        '/sample_recorder': (context) => SampleRecorder(
              notifyParent: () {
                setState(() {});
              },
            ),
        '/backup_manager': (context) => BackupManager(
              notifyParent: () {
                setState(() {});
              },
            ),
      },
      title: 'Turbo Broccoli',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.green[900],
        accentColor: Colors.green[450],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              "Turbo Broccoli ($liveCount)",
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              IconButton(
                  color: (sampleList != null && sampleList.needsUpdate())
                      ? Colors.redAccent
                      : Colors.green,
                  icon: FaIcon(FontAwesomeIcons.weight),
                  onPressed: () {
                    setState(() {
                      if (sampleList.needsUpdate()) {
                        Navigator.pushNamed(context, '/sample_recorder');
                      }
                    });
                  }),
              InkWell(
                onLongPress: () {
                  setState(() {
                    _allowDelete ^= true;
                  });
                },
                child: IconButton(
                    color: _allowDelete ? Colors.red : Colors.green,
                    icon: _allowDelete
                        ? FaIcon(FontAwesomeIcons.trash)
                        : FaIcon(FontAwesomeIcons.trash),
                    onPressed: () {}),
              ),
              IconButton(
                  icon: _showAll
                      ? FaIcon(FontAwesomeIcons.eye)
                      : FaIcon(FontAwesomeIcons.lowVision),
                  onPressed: () {
                    setState(() {
                      _showAll ^= true;
                    });
                  })
            ],
          ),
          drawer: Drawer(
            child: MainMenu(notifyParent: () {
              setState() {}
            }),
          ),
          body: Center(
              child: liveCount > 0
                  ? ListView.builder(
                      itemCount: plantList != null
                          ? min(plantList.plantList.length, liveCount)
                          : 0,
                      itemBuilder: (context, index) {
                        return plantList != null
                            ? Column(children: [
                                InkWell(
                                  child: PlantCard(
                                    tommy: plantList.plantList[index],
                                    index: index,
                                    allowDelete: _allowDelete,
                                    notifyParent: () {
                                      setState(() {});
                                    },
                                  ),
                                  onTap: () {},
                                ),
                              ])
                            : Center();
                      })
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.leaf,
                          size: 150,
                          color: Colors.lightGreen,
                        ),
                        SizedBox(height: 50),
                        Text(
                          'Happy Plants!',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.lightGreen,
                          ),
                          overflow: TextOverflow.visible,
                        )
                      ],
                    )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              print('this button works');
              plantList.actionChanges();
              plantList.orderCollection();
              saveDisk(plantList, zoneList, sampleList);

              setState(() {});
            },
            backgroundColor: Colors.green[400],
            tooltip: 'Action all changes and save.',
            child: FaIcon(FontAwesomeIcons.checkSquare),
          ),
        ),
      ),
    );
  }
}

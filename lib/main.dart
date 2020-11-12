import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_broccoli/shared/card.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'dart:developer';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turbo Broccoli',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.green[900],
        accentColor: Colors.green[450],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {'/': (context) => Home(title: 'Turbo Broccoli')},
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static PlantCollection plantList;
  void populateList() async {
    plantList = await fromDisk();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    populateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: MainMenu(),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: plantList != null ? plantList.plantList.length : 0,
            itemBuilder: (context, index) {
              return plantList != null
                  ? Column(children: [
                      InkWell(
                        child: PlantCard(tommy: plantList.plantList[index]),
                        onTap: () {
                          print(plantList.plantList.removeAt(index));
                          print('attempt remove');
                          setState(() {});
                        },
                      ),
                    ])
                  : Center();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveDisk(plantList);
          setState(() {});
        },
        backgroundColor: Colors.green[400],
        tooltip: 'Save Progress',
        child: Icon(Icons.save),
      ),
    );
  }
}

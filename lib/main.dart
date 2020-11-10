import 'package:flutter/material.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'dart:developer';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //this is some dev code to add a new plant
    PlantCollection plantList = new PlantCollection();
    plantList.addNew(new Plant(
      uid: 5,
      name: 'Jade Plant',
      lastWatered: DateTime(2020, 12, 17),
      previousWater: DateTime(2019, 12, 20),
      nextWater: DateTime(2019, 12, 29),
      dbw: 0,
      multiplier: 0.75,
    ));
    print('Hello');
    inspect(plantList);

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(child: MainMenu()),
      body: Center(
          child: ListView.builder(
        itemCount: 25,
        itemBuilder: (context, index) {
          return Container();
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        backgroundColor: Colors.green[400],
        tooltip: 'Save Progress',
        child: Icon(Icons.save),
      ),
    );
  }
}

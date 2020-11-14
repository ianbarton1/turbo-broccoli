import 'dart:math';

import 'package:flutter/material.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/plant.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          color: Colors.green[900],
          child: Column(
            children: [
              SizedBox(height: 60),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.add),
                        title: Text('Add a New Plant'),
                        onTap: () {
                          setState(() {
                            plantList.addNew(new Plant(
                              uid: rng.nextInt(1000),
                              name: 'Test Plant',
                              previousWater: DateTime(1990, 11, 14),
                              lastWatered: DateTime(2020, 11, 15),
                              dbw: rng.nextInt(30) - 60,
                              multiplier: 0.75,
                              section: rng.nextInt(7),
                              nextWater: DateTime(2020, 11, 15),
                              checkStatus: 0,
                            ));
                            plantList.plantList[plantList.plantList.length - 1]
                                    .nextWater =
                                plantList
                                    .plantList[plantList.plantList.length - 1]
                                    .suggestedWaterDate();
                            Navigator.pushReplacementNamed(context, '/home');
                          });
                        }),
                    ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Remove a Plant'),
                      //onTap: () => Navigator.pushNamed(context, '/home'),
                    ),
                    ListTile(
                      leading: Icon(Icons.search_sharp),
                      title: Text('Plant Query'),
                      // onTap: () => {},
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      //onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Finish and Save Data'),
                      //onTap: () {
                      // Navigator.pushReplacementNamed(context, '/login');
                      //},
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                height: 60,
                child: Text(
                  "Ian Barton",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

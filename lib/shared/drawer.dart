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
                            Navigator.popAndPushNamed(context, '/add_new');
                          });
                        }),
                    ListTile(
                        leading: Icon(Icons.list_alt),
                        title: Text('Section Manager'),
                        onTap: () {
                          setState(() {
                            Navigator.popAndPushNamed(context, '/zone_manager');
                          });
                        }),
                    // ListTile(
                    //   leading: Icon(Icons.search_sharp),
                    //   title: Text('Plant Query'),
                    //   // onTap: () => {},
                    // ),
                    ListTile(
                      leading: Icon(Icons.backup),
                      title: Text('Backup/Restore Data'),
                      onTap: () {
                        setState(() {
                          Navigator.popAndPushNamed(context, '/backup_manager');
                        });
                      },
                    ),
                    // ListTile(
                    //   leading: Icon(Icons.settings),
                    //   title: Text('Settings'),
                    //   //onTap: () {},
                    // ),
                    // ListTile(
                    //   leading: Icon(Icons.exit_to_app),
                    //   title: Text('Finish and Save Data'),
                    //   //onTap: () {
                    //   // Navigator.pushReplacementNamed(context, '/login');
                    //   //},
                    // ),
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

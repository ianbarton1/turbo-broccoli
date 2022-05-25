import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turbo_broccoli/main.dart';

class MainMenu extends StatefulWidget {
  final Function() notifyParent;

  MainMenu({this.notifyParent});
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
                    (zoneList.zoneList.length > 0 &&
                            sampleList.samples.length > 0)
                        ? ListTile(
                            leading: Icon(Icons.add),
                            title: Text('Add a New Plant'),
                            onTap: () {
                              setState(() {
                                Navigator.popAndPushNamed(context, '/add_new');
                              });
                            })
                        : Container(),
                    ListTile(
                        leading: Icon(Icons.list_alt),
                        title: Text('Section Manager'),
                        onTap: () {
                          setState(() {
                            Navigator.popAndPushNamed(context, '/zone_manager');
                          });
                        }),
                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.cloudscale),
                      title: Text('Edit Samples'),
                      onTap: () {
                        setState(() {
                          Navigator.popAndPushNamed(context, '/sample_manager');
                        });
                      },
                    ),

                    ListTile(
                      leading: FaIcon(FontAwesomeIcons.cloudscale),
                      title: Text('Record Samples'),
                      onTap: () {
                        setState(() {
                          Navigator.popAndPushNamed(
                              context, '/sample_recorder');
                        });
                      },
                    ),
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                height: 60,
                child: Text(
                  "Ian Barton version 2022.05.10.00.39",
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

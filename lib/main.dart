import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:turbo_broccoli/pages/activity_preview.dart';
import 'package:turbo_broccoli/pages/backup.dart';
import 'package:turbo_broccoli/pages/new_plant.dart';
import 'package:turbo_broccoli/pages/plant_info.dart';
import 'package:turbo_broccoli/pages/sample_manager.dart';
import 'package:turbo_broccoli/pages/sample_recorder.dart';
import 'package:turbo_broccoli/pages/zone_manager.dart';
import 'package:turbo_broccoli/shared/card.dart';
import 'package:turbo_broccoli/shared/drawer.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:turbo_broccoli/shared/plantWateringProgressIndicator.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';
import 'package:turbo_broccoli/shared/sample_map.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:turbo_broccoli/shared/zone_map.dart';

import 'package:sqflite/sqflite.dart';
import 'package:wakelock/wakelock.dart';

PlantCollection plantList;
ZoneMap zoneList;
SampleMap sampleList;
Random rng = new Random();
bool _showAll = true;
bool _allowDelete = false;
bool _holidayMode = false;

void runBackup(String databasePath) async {
  try {
    File file = File(databasePath);
    File backup = await File(
            '/storage/emulated/0/Documents/TurboBroccoli/backups/backup-${DateFormat('yMdHms').format(DateTime.now())}.db')
        .create(recursive: true);

    final buffer = await file.readAsBytes();
    backup = await backup.writeAsBytes(buffer);

    print("backup should be done?");
  } catch (e) {
    print("error in backup process");
  }
}

Future<bool> requestPermissions() async {
  var status = await Permission.storage.status;

  if (!status.isGranted) {
    await Permission.storage.request();
  }

  var status1 = await Permission.manageExternalStorage.status;
  if (!status1.isGranted) {
    await Permission.manageExternalStorage.request();
  }

  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool permissionCheck = await requestPermissions();

  if (permissionCheck == false) exit(68);

  String documentsPath =
      '/storage/emulated/0/Documents/TurboBroccoli/turbo_broccoli.db';

  // String documentsPath = "/storage/emulated/0/Download/turbo_broccoli.db";

  runBackup(documentsPath);
  final Database database = await openDatabase(documentsPath,
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        print("Database onCreate Method called.");
        db.execute(
          'CREATE TABLE IF NOT EXISTS plants(uid INTEGER PRIMARY KEY, name TEXT, previousWater TEXT, lastWatered TEXT, nextWater TEXT, activeWatered TEXT, waterMode INT, isDelayed INT, delayFactor REAL, sampleID TEXT, isPlantDynamic INTEGER, lastActivitySum REAL, lastActivitySampleCount INTEGER, currentActivitySum REAL, currentActivitySampleCount INTEGER, dbw INTEGER, multiplier REAL, section INTEGER, zone INTEGER, checkStatus INTEGER, dbwLow INTEGER, dbwHigh INTEGER, homeZone TEXT, loadBalancingOffset INTEGER)',
        );

        db.execute(
            "CREATE TABLE IF NOT EXISTS zones (id INTEGER PRIMARY KEY, section_name TEXT)");
        db.execute(
            "CREATE TABLE IF NOT EXISTS samples (id INTEGER PRIMARY KEY, sample_name TEXT, start_value INTEGER)");
        if (version == 1) {
          db.execute(
            'CREATE TABLE IF NOT EXISTS plant_images(pictureid INTEGER PRIMARY KEY, plantid INTEGER NOT NULL, image BLOB, FOREIGN KEY(plantid) REFERENCES plants(uid))',
          );
        } else {
          db.execute(
            'CREATE TABLE IF NOT EXISTS plant_images(pictureid INTEGER PRIMARY KEY, plantid INTEGER NOT NULL, date_time INTEGER, image BLOB, FOREIGN KEY(plantid) REFERENCES plants(uid))',
          );
        }
        return;
      },
      version: 2,
      onOpen: (db) {
        db.execute(
          'CREATE TABLE IF NOT EXISTS plants(uid INTEGER PRIMARY KEY, name TEXT, previousWater TEXT, lastWatered TEXT, nextWater TEXT, activeWatered TEXT, waterMode INT, isDelayed INT, delayFactor REAL, sampleID TEXT, isPlantDynamic INTEGER, lastActivitySum REAL, lastActivitySampleCount INTEGER, currentActivitySum REAL, currentActivitySampleCount INTEGER, dbw INTEGER, multiplier REAL, section INTEGER, zone INTEGER, checkStatus INTEGER, dbwLow INTEGER, dbwHigh INTEGER, homeZone TEXT, loadBalancingOffset INTEGER)',
        );

        db.execute(
            "CREATE TABLE IF NOT EXISTS zones (id INTEGER PRIMARY KEY, section_name TEXT)");
        db.execute(
            "CREATE TABLE IF NOT EXISTS samples (id INTEGER PRIMARY KEY, sample_name TEXT, start_value INTEGER, last_checked TEXT)");
        return db.execute(
          'CREATE TABLE IF NOT EXISTS plant_images(pictureid INTEGER PRIMARY KEY, plantid INTEGER NOT NULL, image BLOB, date_time INTEGER, FOREIGN KEY(plantid) REFERENCES plants(uid))',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion == 1) {
          db.execute("ALTER TABLE plant_images ADD COLUMN date_time INTEGER;");
        }
      });

  runApp(Phoenix(
    child: Home(
      title: 'Turbo Broccoli',
      database: database,
    ),
  ));
}

class Home extends StatefulWidget {
  Home({Key key, this.title, this.database}) : super(key: key);
  final String title;
  final Database database;

  @override
  _HomeState createState() => _HomeState();

  Widget build(BuildContext context) {
    plantList.orderCollection(_showAll);
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Home(
              title: 'Turbo Broccoli',
              database: database,
            ),
      },
    );
  }
}

class _HomeState extends State<Home> {
  void populateList() async {
    // SharedPreferences debug = await SharedPreferences.getInstance();
    // await debug.clear();

    plantList = await fromDisk(widget.database);
    zoneList = await loadZones();
    sampleList = await sampleFromDisk(widget.database);
    if (plantList == null) plantList = new PlantCollection();
    if (zoneList == null) zoneList = new ZoneMap();
    if (sampleList == null) sampleList = new SampleMap();
    setState(() {});
  }

  void updateParent() {
    setState(() {});
    print("update main");
  }

  int liveCount = 0;
  PageController _wateringSessionController =
      new PageController(initialPage: 0, keepPage: true, viewportFraction: 1);

  String areaFilter = "";
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    if (plantList == null) populateList();

    areaFilter = zoneList?.zoneList?.first;
  }

  @override
  Widget build(BuildContext context) {
    if (plantList != null) {
      plantList.orderCollection(_showAll);
      liveCount = _showAll ? plantList.plantList.length : plantList.liveCount();
    }

    //
    if (zoneList != null && !zoneList.zoneList.contains(areaFilter))
      try {
        areaFilter = zoneList?.zoneList?.first;
      } catch (e) {
        areaFilter = "";
      }

    return MaterialApp(
      routes: {
        '/home': (context) => Home(
              title: 'Turbo Broccoli',
            ),
        '/add_new': (context) => NewPlant(
              database: widget.database,
            ),
        '/zone_manager': (context) => ZoneManager(
              notifyParent: () {
                setState(() {});
              },
            ),
        '/sample_manager': (context) => SampleManager(
              notifyParent: () {
                setState(() {});
              },
              database: widget.database,
            ),
        '/sample_recorder': (context) => SampleRecorder(
              notifyParent: () {
                setState(() {});
                saveDisk(plantList, zoneList, sampleList, widget.database);
              },
            ),
        '/backup_manager': (context) => BackupManager(
              widget.database,
              notifyParent: () {
                setState(() {});
              },
            ),
        '/activity_preview': (context) => ActivityPreviewer(),
      },
      title: 'Turbo Broccoli',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.green[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              "($liveCount)",
              style: TextStyle(fontSize: 18),
            ),
            actions: [
              // IconButton(
              //     onPressed: () {
              //       Plant testPlant = Plant();
              //       testPlant.waterPlant();
              //       debugPrint(testPlant.toJson().toString());
              //     },
              //     icon: Icon((Icons.ac_unit))),
              IconButton(
                  color: (sampleList != null && sampleList.needsUpdate())
                      ? Colors.redAccent
                      : Colors.green,
                  icon: FaIcon(FontAwesomeIcons.weightScale),
                  onPressed: () {
                    setState(() {
                      if (sampleList.needsUpdate()) {
                        Navigator.pushNamed(context, '/sample_recorder');
                      }
                    });
                  }),
              // holiday button (temp disabled)
              InkWell(
                enableFeedback: true,
                onLongPress: () {
                  setState(() {
                    _holidayMode ^= true;
                    plantList.changeHolidayMode(_holidayMode, DateTime.now());
                  });
                },
                onDoubleTap: () {
                  debugPrint("attempt to show date picker");
                  if (_holidayMode) {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)))
                        .then((value) {
                      setState(() {
                        value = value
                            .add(Duration(days: -1, hours: 18, minutes: 1));
                        debugPrint("The selected date is $value");
                        plantList.changeHolidayMode(true, value);
                      });
                    });
                  }
                },
                child: IconButton(
                    color: (_holidayMode) ? Colors.yellow : Colors.grey,
                    icon: FaIcon(FontAwesomeIcons.planeDeparture),
                    onPressed: () {}),
              ),
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
                      : FaIcon(FontAwesomeIcons.eyeLowVision),
                  onPressed: () {
                    setState(() {
                      _showAll ^= true;
                      Wakelock.toggle(enable: !_showAll);
                    });
                  })
            ],
          ),
          drawer: Drawer(
            child: MainMenu(notifyParent: () {}),
          ),
          body: Center(
              child: liveCount > 0
                  ? (!_showAll
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomPaint(
                                foregroundPainter: PlantStatusPainter(
                                    plantCollection: plantList,
                                    currentIndex: _wateringSessionController
                                            .positions.isEmpty
                                        ? -1
                                        : currentPageIndex - 1),
                                size: Size(
                                    MediaQuery.of(context).size.width,
                                    (plantList.liveCount() / 10.00).ceil() *
                                        20.00),
                              ),
                            ),
                            Divider(
                              thickness: 2,
                            ),
                            Expanded(child: plantWateringSession(context)),
                          ],
                        )
                      : Column(
                          children: [
                            DropdownButton<String>(
                              value: areaFilter,
                              items: zoneList.zoneList.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  areaFilter = newValue;
                                });
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: plantList != null
                                      ? min(
                                          plantList
                                              .filteredByArea(areaFilter)
                                              .length,
                                          liveCount)
                                      : 0,
                                  itemBuilder: (context, index) {
                                    return plantList != null
                                        ? InkWell(
                                            child: Container(
                                              child: PlantCard(
                                                tommy: plantList.filteredByArea(
                                                    areaFilter)[index],
                                                index: index,
                                                allowDelete: _allowDelete,
                                                notifyParent: updateParent,
                                                database: widget.database,
                                              ),
                                            ),
                                            onTap: () {},
                                          )
                                        : Center();
                                  }),
                            ),
                          ],
                        ))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.faceSmileWink,
                          size: 150,
                          color: Colors.lightGreen,
                        ),
                        SizedBox(height: 50),
                        Text(
                          'Nothing to do now',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.lightGreen,
                          ),
                          overflow: TextOverflow.visible,
                        )
                      ],
                    )),
        ),
      ),
    );
  }

  PageView plantWateringSession(BuildContext context) {
    return PageView.builder(
        onPageChanged: (value) {
          currentPageIndex = value;
          updateParent();
        },
        controller: _wateringSessionController,
        itemCount: plantList != null
            ? min(plantList.plantList.length, liveCount) + 2
            : 0,
        itemBuilder: (context, index) {
          return plantList != null
              ? (index < min(plantList.plantList.length, liveCount) + 1 &&
                      index > 0)
                  ? InkWell(
                      child: Container(
                        height: 1000,
                        child: PlantInfo(
                          updateParent: () {
                            updateParent();
                          },
                          showAppBar: false,
                          database: widget.database,
                          plant: plantList.plantList[index - 1],
                          drawIndex: index - 1,
                        ),
                      ),
                      onTap: () {},
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Finish", style: TextStyle(fontSize: 60)),
                          SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  iconSize: 60,
                                  color: Colors.red[400],
                                  onPressed: () {
                                    _wateringSessionController.animateToPage(
                                        _wateringSessionController.page
                                                    .toInt() ==
                                                0
                                            ? min(plantList.plantList.length,
                                                liveCount)
                                            : 1,
                                        curve: Curves.decelerate,
                                        duration: Duration(milliseconds: 300));
                                  },
                                  icon: FaIcon(
                                    index == 0
                                        ? FontAwesomeIcons.anglesRight
                                        : FontAwesomeIcons.anglesLeft,
                                    size: 60.00,
                                  )),
                              SizedBox(
                                width: 50,
                              ),
                              IconButton(
                                  iconSize: 60,
                                  color: Colors.green[400],
                                  onPressed: () {
                                    print('this button works');
                                    plantList.actionChanges();
                                    plantList.orderCollection(_showAll);
                                    saveDisk(plantList, zoneList, sampleList,
                                        widget.database);
                                    _wateringSessionController.animateToPage(1,
                                        curve: Curves.decelerate,
                                        duration: Duration(milliseconds: 300));
                                    setState(() {});
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.thumbsUp,
                                    size: 60.00,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    )
              : Center();
        });
  }
}

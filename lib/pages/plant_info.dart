import 'dart:typed_data';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/pages/new_plant.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turbo_broccoli/shared/plant_collection.dart';

import '../shared/plantWateringProgressIndicator.dart';

class PlantInfo extends StatefulWidget {
  final Plant plant;
  final Database database;
  final bool showAppBar;
  final int drawIndex;
  PlantInfo(
      {this.plant,
      this.database,
      this.updateParent,
      this.showAppBar = true,
      this.drawIndex = 0});
  dynamic plantPicture;
  Function updateParent;

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {
  ImagePicker picker = new ImagePicker();
  List<Image> plantPictureReal;
  List<bool> isSelected = List.filled(3, false);
  List<Color> selectedColorList = [
    Color.fromRGBO(32, 32, 32, 1.0),
    Color.fromRGBO(64, 0, 0, 1.0),
    Color.fromRGBO(0, 0, 64, 1.0)
  ];
  int pictureIndex = 0;

  @override
  void initState() {
    super.initState();
    print("Database ${widget.database}");
    updateImage();
    switch (widget.plant.checkStatus) {
      case (0):
        isSelected[1] = true;
        break;
      case (1):
        isSelected[0] = true;
        break;
      case (2):
        isSelected[2] = true;
        break;
    }
  }

  void updateImage() async {
    plantPictureReal = widget.plant.plantImage;
    setState(() {});
  }

  void fullScreenViewer(ImageProvider image) {
    showDialog(
        context: context,
        builder: (context) {
          return InteractiveViewer(
              maxScale: 10.0,
              minScale: 1.000,
              child: Image(
                image: image,
              ));
        });
  }

  void bottomBar() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () async {
                        _getImage(ImageSource.gallery, widget.database);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _getImage(ImageSource.camera, widget.database);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _getImage(ImageSource imageSource, Database database) async {
    FocusScope.of(context).unfocus();
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(
        source: imageSource, maxWidth: 1000, maxHeight: 1000, imageQuality: 75);
    Uint8List imageContents = await pickedFile.readAsBytes();

    if (pickedFile != null) {
      // database.delete("plant_images",
      //     where: "plantid = ?", whereArgs: [widget.plant.uid]);
      await database.execute(
          'INSERT INTO plant_images(plantid, image, date_time) VALUES (?, ?, ?)',
          [
            widget.plant.uid,
            imageContents,
            (DateTime.now().millisecondsSinceEpoch / 1000).floor()
          ]);
    }

    await widget.plant.getDatabaseImage();
    updateImage();
  }

  @override
  Widget build(BuildContext context) {
    int pictureAge = widget.plant.plantDateTime[pictureIndex]
            ?.difference(DateTime.now())
            ?.inDays
            ?.abs() ??
        0;
    // super.build(context);
    return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text('View Plant'),
                centerTitle: true,
                actions: [
                  IconButton(
                      icon: FaIcon(FontAwesomeIcons.penToSquare),
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
                                      database: widget.database,
                                    )));
                      }),
                ],
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () => bottomBar(),
          child: FaIcon(FontAwesomeIcons.camera),
          backgroundColor: Colors.lightGreen,
        ),
        body: AnimatedContainer(
          height: 1000,
          duration: Duration(milliseconds: 500),
          color: selectedColorList[widget.plant.checkStatus],
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.green[900],
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.plant.homeZone,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FaIcon(
                                FontAwesomeIcons.clock,
                                color: widget.plant.isDelayed
                                    ? Colors.yellow
                                    : Colors.black38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FaIcon(FontAwesomeIcons.chartBar,
                                  color: widget.plant.isPlantDynamic
                                      ? Colors.yellow
                                      : Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Center(
                          child: InkWell(
                        onTap: () => fullScreenViewer(
                            widget.plant.plantImage[pictureIndex].image),
                        child: Stack(children: [
                          CircleAvatar(
                            foregroundImage: plantPictureReal == null
                                ? null
                                : (plantPictureReal.length > 0)
                                    ? widget
                                        .plant.plantImage[pictureIndex].image
                                    : null,
                            radius: MediaQuery.of(context).size.width / 2.5,
                          ),
                          Chip(
                            padding: EdgeInsets.all(0),
                            backgroundColor: Colors.green[900],
                            label: Text(
                              '${widget.plant.uid}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                              ),
                            ),
                          ),
                        ]),
                      )),
                    ),
                    plantPictureReal.length > 0
                        ? Text(
                            "Photo Taken on : ${widget.plant.plantDateTime[pictureIndex]}",
                            //FIXME: the number of days between pictures before turning red should be plant-specific. For now I will have one month.
                            style: pictureAge >= 30
                                ? TextStyle(color: Colors.red)
                                : null,
                          )
                        : Container(),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  pictureIndex--;
                                  if (pictureIndex < 0) pictureIndex = 0;
                                });
                              },
                              icon: FaIcon(FontAwesomeIcons.backward)),
                          Text(
                              "${pictureIndex + 1} / ${plantPictureReal.length}"),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  pictureIndex++;
                                  if (pictureIndex >
                                      plantPictureReal.length - 1)
                                    pictureIndex = plantPictureReal.length - 1;
                                });
                              },
                              icon: FaIcon(FontAwesomeIcons.forward)),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.green[900],
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "${widget.plant.name}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                      child: Container(
                        child: LayoutBuilder(builder: (context, constraints) {
                          return ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                widget.plant.isLocked()
                                    ? Colors.black45
                                    : Colors.transparent,
                                BlendMode.xor),
                            child: !widget.showAppBar
                                ? ToggleButtons(
                                    constraints: BoxConstraints.expand(
                                        width: constraints.maxWidth / 3 - 2,
                                        height: 48),
                                    children: <Widget>[
                                      Container(child: Icon(Icons.thumb_down)),
                                      Container(child: Icon(Icons.circle)),
                                      Container(child: Icon(Icons.thumb_up)),
                                    ],
                                    onPressed: (int index) {
                                      setState(() {
                                        if (!widget.plant.isLocked()) {
                                          switch (index) {
                                            case (0):
                                              widget.plant.checkStatus = 1;
                                              break;
                                            case (1):
                                              widget.plant.checkStatus = 0;
                                              break;
                                            case (2):
                                              widget.plant.checkStatus = 2;
                                              break;
                                          }

                                          saveDisk(plantList, zoneList,
                                              sampleList, widget.database);
                                          for (int buttonIndex = 0;
                                              buttonIndex < isSelected.length;
                                              buttonIndex++) {
                                            if (buttonIndex == index) {
                                              isSelected[buttonIndex] = true;
                                            } else {
                                              isSelected[buttonIndex] = false;
                                            }
                                          }
                                        }
                                      });
                                      widget.updateParent();
                                    },
                                    isSelected: isSelected,
                                  )
                                : Container(),
                          );
                        }),
                      ),
                    ),
                    Text(widget.plant
                        .filterDatesBetween(DateTime.now())
                        .toString()),
                    ExpansionTile(
                      title: Text("Debug Information"),
                      children: [
                        Column(
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
                            // Text(
                            //   'Next Check on: ${DateFormat('yyyy-MM-dd-hh-mm-ss').format(widget.plant.nextWater)}',
                            //   style: TextStyle(fontSize: 20),
                            // ),
                            Text(
                              'Next Check on: ${widget.plant.nextWater}',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              'Scheduled Date on: ${widget.plant.scheduledDate()}',
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // @override
  // bool get wantKeepAlive => true;
}

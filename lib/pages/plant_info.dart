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

class PlantInfo extends StatefulWidget {
  final Plant plant;
  final Database database;
  PlantInfo({this.plant, this.database, this.updateParent});
  dynamic plantPicture;
  Function updateParent;

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo>
    with AutomaticKeepAliveClientMixin {
  ImagePicker picker = new ImagePicker();
  Image plantPictureReal;
  List<bool> isSelected = List.filled(3, false);

  @override
  void initState() {
    super.initState();

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
    getDatabaseImage();
  }

  void getDatabaseImage() async {
    widget.plantPicture = await widget.database.query("plant_images",
        columns: ["image"],
        where: 'plantid = ?',
        whereArgs: [widget.plant.uid],
        limit: 1);

    widget.plantPicture = widget.plantPicture[0]['image'];
    print(widget.plantPicture.runtimeType);
    print(widget.plantPicture);
    plantPictureReal = new Image.memory(widget.plantPicture);
    print(plantPictureReal.runtimeType);
    setState(() {});
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
    final pickedFile = await picker.getImage(
        source: imageSource, maxWidth: 1000, maxHeight: 1000, imageQuality: 75);
    Uint8List imageContents = await pickedFile.readAsBytes();
    print("the bytes follow:");
    print(imageContents);

    if (pickedFile != null) {
      database.delete("plant_images",
          where: "plantid = ?", whereArgs: [widget.plant.uid]);
      await database.execute(
          'INSERT INTO plant_images(plantid, image) VALUES (?, ?)',
          [widget.plant.uid, imageContents]);
      getDatabaseImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('View Plant'),
        //   centerTitle: true,
        //   actions: [
        //     IconButton(
        //         icon: FaIcon(FontAwesomeIcons.edit),
        //         onPressed: () {
        //           print('im doing something');
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => NewPlant(
        //                         plant: widget.plant,
        //                         notifyParent: () {
        //                           setState(() {});
        //                         },
        //                         database: widget.database,
        //                       )));
        //         }),
        //   ],
        // ),
        body: Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                child: Center(
                    child: InkWell(
                  onTap: () => bottomBar(),
                  child: CircleAvatar(
                    foregroundImage: plantPictureReal == null
                        ? null
                        : plantPictureReal.image,
                    radius: 125,
                  ),
                )),
              ),
              Text(
                "${widget.plant.uid} : ${widget.plant.name}",
                style: TextStyle(fontSize: 24),
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
                      child: ToggleButtons(
                        constraints: BoxConstraints.expand(
                            width: constraints.maxWidth / 3 - 2, height: 48),
                        children: <Widget>[
                          Container(child: Icon(Icons.stop_circle_outlined)),
                          Container(child: Icon(Icons.blur_circular_outlined)),
                          Container(child: Icon(Icons.check_circle_outline)),
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

                              saveDisk(plantList, zoneList, sampleList,
                                  widget.database);
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
                      ),
                    );
                  }),
                ),
              ),
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
    ));
  }

  @override
  bool get wantKeepAlive => true;
}

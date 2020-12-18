import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/pages/new_plant.dart';
import 'package:turbo_broccoli/pages/plant_info.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:intl/intl.dart';

class PlantCard extends StatefulWidget {
  final Function() notifyParent;
  final Plant tommy;
  final int index;
  final bool allowDelete;
  //constructor?
  PlantCard(
      {Key key,
      this.tommy,
      this.index,
      this.allowDelete,
      @required this.notifyParent})
      : super(key: key);

  @override
  _PlantCardState createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  Color tileColor;
  Color textColor;

  @override
  Widget build(BuildContext context) {
    switch (widget.tommy.checkStatus) {
      case (0):
        {
          tileColor = Colors.blueGrey[200];
          textColor = Colors.black;
        }
        break;
      case (1):
        {
          tileColor = Colors.red[500];
          textColor = Colors.white;
        }
        break;
      case (2):
        {
          tileColor = Colors.blue[900];
          textColor = Colors.white;
        }
        break;
      default:
        {
          tileColor = Colors.blueAccent;
          textColor = Colors.black;
        }
    }
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
          widget.tommy.needsUpdate() ? Colors.black45 : Colors.transparent,
          BlendMode.darken),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
        child: Card(
          color: tileColor,
          child: ListTile(
            tileColor: tileColor,
            // title: Text(
            //   '${widget.tommy.uid} - ${widget.tommy.name} - ${widget.tommy.section} - ${DateFormat('yyyy-MM-dd').format(widget.tommy.nextWater)}',
            //   style: TextStyle(color: textColor),
            title: Column(
              children: [
                Row(
                  children: [
                    Chip(
                      padding: EdgeInsets.all(0),
                      backgroundColor: Colors.black,
                      label: Text(
                        '${widget.tommy.uid}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            '${widget.tommy.name}',
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 25,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              'Last Watered on: ${DateFormat('yyyy-MM-dd').format(widget.tommy.lastWatered)}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal),
                            ),
                            Text(
                              'Next check due on: ${DateFormat('yyyy-MM-dd').format(widget.tommy.nextWater)}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal),
                            ),
                            Text(
                              'Home Zone: ${widget.tommy.homeZone}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontStyle: FontStyle.normal),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            subtitle: Column(
              children: <Widget>[
                Container(
                    child: Row(
                  children: <Widget>[
                    Expanded(
                      child: IconButton(
                        iconSize: 45,
                        icon: FaIcon(FontAwesomeIcons.check, color: textColor),
                        onPressed: () {
                          setState(() {
                            // widget.tommy.checkStatus = 2;
                            if (!widget.tommy.needsUpdate())
                              plantList.plantList[widget.index].checkStatus =
                                  plantList.plantList[widget.index]
                                              .checkStatus ==
                                          2
                                      ? 0
                                      : 2;
                            saveDisk(plantList, zoneList, sampleList);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        iconSize: 40,
                        icon: FaIcon(FontAwesomeIcons.info, color: textColor),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PlantInfo(plant: widget.tommy)));
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        iconSize: 45,
                        icon: FaIcon(FontAwesomeIcons.ban, color: textColor),
                        onPressed: () {
                          setState(() {
                            if (!widget.tommy.needsUpdate())
                              plantList.plantList[widget.index].checkStatus =
                                  plantList.plantList[widget.index]
                                              .checkStatus ==
                                          1
                                      ? 0
                                      : 1;
                            saveDisk(plantList, zoneList, sampleList);
                          });
                        },
                      ),
                    ),
                    widget.allowDelete
                        ? FlatButton(
                            onLongPress: () {
                              plantList.plantList.removeAt(widget.index);
                              print('attempt remove');
                              widget.notifyParent();
                            },
                            onPressed: () {},
                            child: IconButton(
                              iconSize: 45,
                              icon: FaIcon(FontAwesomeIcons.trash,
                                  color: textColor),
                              onPressed: () {},
                            ),
                          )
                        : Container(),
                  ],
                ))
              ],
            ),

            // onTap: () {},
          ),
        ),
      ),
    );
  }
}

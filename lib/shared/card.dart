import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/pages/plant_info.dart';
import 'package:turbo_broccoli/shared/plant.dart';

class PlantCard extends StatefulWidget {
  final Function() notifyParent;
  final Plant tommy;
  final int index;
  final bool allowDelete;
  final Database database;
  //constructor?
  PlantCard(
      {Key key,
      this.tommy,
      this.index,
      this.allowDelete,
      @required this.notifyParent,
      this.database})
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
          widget.tommy.isLocked() ? Colors.black45 : Colors.transparent,
          BlendMode.darken),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
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
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: tileColor,
                      ),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.clock,
                            color: widget.tommy.isDelayed
                                ? Colors.black
                                : Colors.transparent,
                          ),
                          FaIcon(FontAwesomeIcons.chartBar,
                              color: widget.tommy.isPlantDynamic
                                  ? Colors.black
                                  : Colors.transparent)
                        ],
                      ),
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         child: Column(
                //           children: [
                //             Text(
                //               'Last Watered on: ${DateFormat('yyyy-MM-dd').format(widget.tommy.lastWatered)}',
                //               overflow: TextOverflow.visible,
                //               style: TextStyle(
                //                   color: textColor,
                //                   fontSize: 15,
                //                   fontStyle: FontStyle.normal),
                //             ),
                //             Text(
                //               'Next check due on: ${DateFormat('yyyy-MM-dd').format(widget.tommy.nextWater)}',
                //               overflow: TextOverflow.visible,
                //               style: TextStyle(
                //                   color: textColor,
                //                   fontSize: 15,
                //                   fontStyle: FontStyle.normal),
                //             ),
                //             Text(
                //               'Home Zone: ${widget.tommy.homeZone}',
                //               overflow: TextOverflow.visible,
                //               style: TextStyle(
                //                   color: textColor,
                //                   fontSize: 15,
                //                   fontStyle: FontStyle.normal),
                //             ),
                //           ],
                //         ),
                //       ),
                //     )
                //   ],
                // )
              ],
            ),
            subtitle: Column(
              children: <Widget>[
                Container(
                    child: Row(
                  children: <Widget>[
                    // Expanded(
                    //   child: IconButton(
                    //     iconSize: 45,
                    //     icon: (widget.tommy.isDelayed &&
                    //             widget.tommy.waterMode == false)
                    //         ? FaIcon(FontAwesomeIcons.calendarCheck,
                    //             color: textColor)
                    //         : FaIcon(FontAwesomeIcons.check, color: textColor),
                    //     onPressed: () {
                    //       setState(() {
                    //         // widget.tommy.checkStatus = 2;
                    //         if (!widget.tommy.isLocked())
                    //           plantList.plantList[widget.index].checkStatus =
                    //               plantList.plantList[widget.index]
                    //                           .checkStatus ==
                    //                       2
                    //                   ? 0
                    //                   : 2;
                    //         saveDisk(plantList, zoneList, sampleList,
                    //             widget.database);
                    //       });
                    //     },
                    //   ),
                    // ),
                    Expanded(
                      child: IconButton(
                        iconSize: 40,
                        icon: FaIcon(FontAwesomeIcons.info, color: textColor),
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlantInfo(
                                            plant: widget.tommy,
                                            database: widget.database,
                                          )))
                              .then((value) => {widget.notifyParent()});
                        },
                      ),
                    ),
                    // Container(
                    //   child: (widget.tommy.isDelayed == false ||
                    //           widget.tommy.waterMode == false)
                    //       ? Expanded(
                    //           child: IconButton(
                    //             iconSize: 45,
                    //             icon: FaIcon(FontAwesomeIcons.ban,
                    //                 color: textColor),
                    //             onPressed: () {
                    //               setState(() {
                    //                 if (!widget.tommy.isLocked())
                    //                   plantList.plantList[widget.index]
                    //                       .checkStatus = plantList
                    //                               .plantList[widget.index]
                    //                               .checkStatus ==
                    //                           1
                    //                       ? 0
                    //                       : 1;
                    //                 saveDisk(plantList, zoneList, sampleList,
                    //                     widget.database);
                    //               });
                    //             },
                    //           ),
                    //         )
                    //       : Container(),
                    // ),
                    widget.allowDelete
                        ? TextButton(
                            onLongPress: () {
                              plantList.plantList[widget.index]
                                  .removeAllPictures();
                              plantList.removePlant(
                                  widget.tommy.uid, widget.database);
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

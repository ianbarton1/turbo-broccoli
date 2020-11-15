import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:turbo_broccoli/main.dart';
import 'package:turbo_broccoli/shared/file_ops.dart';
import 'package:turbo_broccoli/shared/plant.dart';
import 'package:intl/intl.dart';

class PlantCard extends StatefulWidget {
  final Plant tommy;
  final int index;
  //constructor?
  PlantCard({this.tommy, this.index});

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Card(
        color: tileColor,
        child: ListTile(
          tileColor: tileColor,
          title: Text(
            '${widget.tommy.uid} - ${widget.tommy.name} - ${widget.tommy.section} - ${DateFormat('yyyy-MM-dd').format(widget.tommy.nextWater)}',
            style: TextStyle(color: textColor),
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
                          plantList.plantList[widget.index].checkStatus =
                              plantList.plantList[widget.index].checkStatus == 2
                                  ? 0
                                  : 2;
                          saveDisk(plantList);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      iconSize: 40,
                      icon: FaIcon(FontAwesomeIcons.info, color: textColor),
                      onPressed: () {},
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      iconSize: 45,
                      icon: FaIcon(FontAwesomeIcons.ban, color: textColor),
                      onPressed: () {
                        setState(() {
                          plantList.plantList[widget.index].checkStatus =
                              plantList.plantList[widget.index].checkStatus == 1
                                  ? 0
                                  : 1;
                          saveDisk(plantList);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      iconSize: 45,
                      icon: FaIcon(FontAwesomeIcons.eraser, color: textColor),
                      onPressed: () {
                        setState(() {
                          plantList.plantList[widget.index].checkStatus = 0;
                          saveDisk(plantList);
                        });
                      },
                    ),
                  ),
                ],
              ))
            ],
          ),

          // onTap: () {},
        ),
      ),
    );
  }
}

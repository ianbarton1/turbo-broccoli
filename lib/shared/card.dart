import 'package:flutter/material.dart';
import 'package:turbo_broccoli/shared/plant.dart';

class PlantCard extends StatelessWidget {
  final Plant tommy;
  //constructor?
  PlantCard({this.tommy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Card(
        child: ListTile(
          title: Text('${tommy.uid} - ${tommy.name}'),
          subtitle: Text('This is a log, click into it.'),
          // onTap: () {},
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pbl_biodigester/app.dart';

class StatusCard extends StatelessWidget {
    final String sensorTag;
    final String sensorValue;
    final int sensorID;

    const StatusCard(this.sensorTag, this.sensorValue, this.sensorID, {super.key});

    @override 
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: () => handleOnTap(context, sensorID),
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: Colors.white70,
                        width: 0.75,
                    )
                ),
                padding: EdgeInsets.all(14.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Text(
                            sensorTag,
                        ),
                        Text(
                            sensorValue,
                            style: TextStyle(
                                fontSize: 36.0,
                            ),
                        ),
                    ],
                )
            )
        );
    }

    handleOnTap(BuildContext context, int id) {
        Navigator.pushNamed(context, detailScreen, arguments: { "id" : id });
    }
}

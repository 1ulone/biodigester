import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pbl_biodigester/app/database_service.dart';

class DetailScreen extends StatefulWidget {
    final int searchID;
    const DetailScreen(this.searchID, {super.key});

    @override
    State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
    String searchTag = '';
    String value = '...';

    @override
    void initState() {
        super.initState();
        setState(() { searchTag = widget.searchID.toString(); });
        _loadData();
    }

    Future<void> _loadData() async {
        DataSnapshot? snapshot = await DatabaseService().read(path: '/SENSOR_$searchTag');
        if (snapshot == null) {
            log('/SENSOR_$searchTag');
            return;
        }

        setState(() { value = snapshot.value.toString();} );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    'SENSOR $searchTag',
                    style: TextStyle(
                        color: Colors.white,
                    ),
                ),
                iconTheme: IconThemeData(
                    color: Colors.white,
                ),
                backgroundColor: Colors.transparent,
                toolbarHeight: 72.0,
            ),
            body: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                        children: [
                            Container(
                                margin: EdgeInsets.all(8.0),
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                        color: Colors.white70,
                                        width: 0.75,
                                        )
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                        Text('Sensor $searchTag'),
                                        Container(
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(value, style: TextStyle(fontSize: 28.0),)
                                        )
                                    ],
                                )
                            ),
                            Text('Description 2'),
                            Text('Description 3'),
                        ]
                    )
                )
            )
        );
    }
}

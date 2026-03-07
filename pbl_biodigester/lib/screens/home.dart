import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:pbl_biodigester/app.dart';
import 'package:pbl_biodigester/app/database_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pbl_biodigester/models/card_rounded.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override 
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final double defaultPadding = 16.0;
    late StreamSubscription<DatabaseEvent> _subscription;

    List<Map<String, dynamic>> logs = [];
    bool isOn = false;

    @override
    void initState() {
        super.initState();
        _subscribeToData();
    }

    void _subscribeToData() {
        _subscription = FirebaseDatabase.instance
            .ref('/biodigester_logs')
            .orderByKey()
            .limitToLast(1)
            .onValue // This replaces .get()
            .listen((event) {
                final snapshot = event.snapshot;

                if (!snapshot.exists || snapshot.value == null) {
                    return;
                }

                // Firebase returns a Map of objects when using limitToLast
                final Map<dynamic, dynamic> dataMap = snapshot.value as Map<dynamic, dynamic>;
                final key = dataMap.keys.first;
                final value = dataMap[key];

                setState(() {
                        logs = [{
                        'hash_id': key.toString(),
                        'timestamp': value['timestamp'],
                        'input_data': Map<String, dynamic>.from(value['input_data']),
                        'ai_analysis': Map<String, dynamic>.from(value['ai_analysis']),
                    }];
                });
            });
    }

    @override
    void dispose() {
        _subscription.cancel();
        super.dispose();
    }

    @override 
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    'BIODIGESTER',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0
                    ),
                ),
                centerTitle: false,
                titleSpacing: 20.0,
                toolbarHeight: 72.0,
                backgroundColor: Colors.transparent,
            ),
            body: Container(
                padding: EdgeInsets.fromLTRB(defaultPadding, 0, defaultPadding, 0),
                child: Column(
                    spacing: defaultPadding,
                    children: [
                        Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                    BoxShadow(
                                        color: logs[0]['ai_analysis']['status'] == 'OPTIMAL' ? 
                                            Colors.white70 : 
                                            logs[0]['ai_analysis']['status'] == 'WARNING' ? 
                                            Colors.yellow.withAlpha(200) : 
                                            logs[0]['ai_analysis']['status'] == 'CRITICAL'
                                            ? Colors.red.withAlpha(200) : Colors.white12,
                                        spreadRadius: 0.25,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                    )
                                ],
                                borderRadius: BorderRadius.circular(12.0),
                                color: logs[0]['ai_analysis']['status'] == 'OPTIMAL' ? 
                                    Colors.white70 : 
                                    logs[0]['ai_analysis']['status'] == 'WARNING' ? 
                                    Colors.yellow : 
                                    logs[0]['ai_analysis']['status'] == 'CRITICAL'
                                    ? Colors.red : Colors.white12,
                            ),
                            padding: EdgeInsets.all(defaultPadding /2),
                            alignment: Alignment.center,
                            child: Text(
                                'Status Biodigester : ${logs[0]['ai_analysis']['status']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: logs[0]['ai_analysis']['status'] == 'OPTIMAL' ? 
                                        Colors.black87 : 
                                        logs[0]['ai_analysis']['status'] == 'WARNING' ? 
                                        Colors.black54 : 
                                        logs[0]['ai_analysis']['status'] == 'CRITICAL'
                                        ? Colors.black54 : Colors.white,
                                ),
                            ),
                        ),
                        Row(
                            spacing: defaultPadding,
                            children: [
                                CardRounded(
                                    height: 80.0,
                                    width: 162.0,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                            Text(
                                                "Anomali Utama",
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w300
                                                ),
                                            ),
                                            Text(
                                                "-",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600
                                                ),
                                            ),
                                        ]
                                    )
                                ),
                                GestureDetector(
                                    onTap: () { handleOnTap(context, logs[0]['ai_analysis']['status'], logs[0]['ai_analysis']['diagnostic_reasoning']); },
                                    child: CardRounded(
                                        height: 80.0,
                                        width: 165.0,
                                        child: Text(
                                            "Analisis kondisi biodigester",
                                            style: TextStyle(
                                                fontSize: 16.0
                                                ),
                                            textAlign: TextAlign.center,
                                        )
                                    )
                                )
                            ],
                        ),
                        CardRounded(
                            padding: Padding(
                                padding : EdgeInsets.fromLTRB(defaultPadding, 32.0, defaultPadding, 0)
                            ),
                            width: double.infinity,
                            height: 300.0,
                            child: Container(
                                padding: EdgeInsets.fromLTRB(defaultPadding*1.5, 0, defaultPadding*1.5, 0),
                                height: 200.0,
                                child: KdGaugeView(
                                    minSpeed: 0,
                                    maxSpeed: 100,
                                    speed: 100,
                                    animate: true,
                                    gaugeWidth: 28.0,
                                    duration: Duration(seconds: 5),
                                    minMaxTextStyle: TextStyle(color: Colors.transparent),
                                    speedTextStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 72.0
                                    ),
                                    unitOfMeasurementTextStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                    ),
                                    unitOfMeasurement: "Fuel Left (%)",
                                    alertSpeedArray: [16.5, 50, 83.5],
                                    alertColorArray: [Colors.red, Colors.orange, Colors.green],
                                )
                            ) 
                        ),
                        GestureDetector(
                            onTap : () async {
                                isOn = !isOn;
                                if (isOn)
                                    { DatabaseService().create(path: '/state', data: {'toggle':1}); }
                                else 
                                    { DatabaseService().create(path: '/state', data: {'toggle':0}); }
                            },
                            child: Container (

                                padding: EdgeInsets.all(defaultPadding),
                                decoration: BoxDecoration(
                                    color: isOn ? Colors.green : Colors.red, 
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                        BoxShadow(
                                            color: isOn ? Colors.green.withAlpha(200) : Colors.red.withAlpha(200) ,
                                            spreadRadius: 0.25,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                        )
                                    ],
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        Text(
                                            isOn ? "Matikan Biodigester" : "Nyalakan Biodigester",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600
                                            ),
                                        ),
                                        Image.asset(
                                            'assets/images/power.png',
                                            width: 32,
                                            height: 32,
                                        )
                                    ],
                                ),
                            )
                        )
                    ],
                ),
            ),
        );
    }

    handleOnTap(BuildContext context, String status, String diagnosis) {
        Navigator.pushNamed(context, answerScreen, arguments: { "status" : status, "diagnosis" : diagnosis });
    }

}

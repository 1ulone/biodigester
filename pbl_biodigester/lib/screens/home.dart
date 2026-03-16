import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kdgaugeview/kdgaugeview.dart';
import 'package:pbl_biodigester/app.dart';
import 'package:pbl_biodigester/app/api_service.dart';
import 'package:pbl_biodigester/models/card_rounded.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override 
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final GlobalKey<KdGaugeViewState> _gaugeKey = GlobalKey<KdGaugeViewState>();
    final double defaultPadding = 16.0;
    final ApiService _api = ApiService();
    Timer? _timer;
    double _fuel = 0.0;
    String _aiStatus = "";

    @override
    void initState() {
      super.initState();
      _fetchData();
      // Call every 5 seconds
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        final fuel = await _api.fetchFuelStatus();
        // final result = await _api.fetchAiAnalysis();

        setState(() => _fuel = fuel);
        _gaugeKey.currentState?.updateSpeed(
            fuel, 
            animate: true, 
            duration: const Duration(milliseconds: 1000)
        );
      });
    }

    // Call this from your custom button's onPressed
    @override
    void dispose() {
      _timer?.cancel();
      super.dispose();
    }

    Future<void> _fetchData() async {
        final result = await _api.fetchAiAnalysis();
        setState(() => _aiStatus = result['ai_analysis']['status'] );
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
                                        color: _aiStatus == 'OPTIMAL' ? 
                                            Colors.white70 : 
                                            _aiStatus == 'WARNING' ? 
                                            Colors.yellow.withAlpha(200) : 
                                            _aiStatus == 'CRITICAL'
                                            ? Colors.red.withAlpha(200) : Colors.white12,
                                        spreadRadius: 0.25,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                    )
                                ],
                                borderRadius: BorderRadius.circular(12.0),
                                color: _aiStatus == 'OPTIMAL' ? 
                                    Colors.white70 : 
                                    _aiStatus == 'WARNING' ? 
                                    Colors.yellow : 
                                    _aiStatus == 'CRITICAL'
                                    ? Colors.red : Colors.white12,
                            ),
                            padding: EdgeInsets.all(defaultPadding /2),
                            alignment: Alignment.center,
                            child: Text(
                                'Status Biodigester : $_aiStatus',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _aiStatus == 'OPTIMAL' ? 
                                        Colors.black87 : 
                                        _aiStatus == 'WARNING' ? 
                                        Colors.black54 : 
                                        _aiStatus == 'CRITICAL'
                                        ? Colors.black54 : Colors.white,
                                ),
                            ),
                        ),
                        Row(
                            spacing: defaultPadding,
                            children: [
                                GestureDetector(
                                    onTap : () { handleOnRaw(context); },
                                    child: CardRounded(
                                        height: 80.0,
                                        width: 162.0,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                Text(
                                                    "Lihat Data Mentah",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w600,
                                                    ),
                                                ),
                                            ]
                                        )
                                    )
                                ),
                                GestureDetector(
                                    onTap: () { handleOnTap(context); },
                                    child: CardRounded(
                                        height: 80.0,
                                        width: 165.0,
                                        child: Text(
                                            "Analisis kondisi biodigester",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
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
                                    key: _gaugeKey,
                                    minSpeed: 0,
                                    maxSpeed: 100,
                                    speed: _fuel,
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
                                    unitOfMeasurement: "Sisa Gas (%)",
                                    alertSpeedArray: [16.5, 50, 83.5],
                                    alertColorArray: [Colors.red, Colors.orange, Colors.green],
                                )
                            ) 
                        ),
                        GestureDetector(
                            onTap : () async {
                                // isOn = !isOn;
                                // if (isOn)
                                //     { DatabaseService().create(path: '/state', data: {'toggle':1}); }
                                // else 
                                //     { DatabaseService().create(path: '/state', data: {'toggle':0}); }
                            },
                            child: Container (

                                padding: EdgeInsets.all(defaultPadding),
                                decoration: BoxDecoration(
                                    // color: isOn ? Colors.green : Colors.red, 
                                    color : Colors.red,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                        BoxShadow(
                                            // color: isOn ? Colors.green.withAlpha(200) : Colors.red.withAlpha(200) ,
                                            color : Colors.red.withAlpha(200),
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
                                            // isOn ? "Matikan Biodigester" : "Nyalakan Biodigester",
                                            "Nyalakan Biodigester",
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

    handleOnTap(BuildContext context) {
        Navigator.pushNamed(context, answerScreen);
    }

    handleOnRaw(BuildContext context) {
        Navigator.pushNamed(context, detailScreen);
    }
}

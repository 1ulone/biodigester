import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl_biodigester/app/api_service.dart';
import 'package:pbl_biodigester/models/card_rounded.dart';

class DetailScreen extends StatefulWidget {
    const DetailScreen({super.key});

    @override
    State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
    final ApiService apiService = ApiService();
    Timer? _timer;
    Map<String, dynamic>? _sensorData;
    String _errorMessage = '';

    @override
        void initState() {
            super.initState();
            _fetchData();
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                    _fetchData();
                    });
        }

    Future<void> _fetchData() async {
        try {
            final data = await apiService.fetchRawSensorData();
            if (mounted) {
                setState(() {
                        _sensorData = data;
                        _errorMessage = '';
                        });
            }
        } catch (e) {
            if (mounted) {
                setState(() {
                        _errorMessage = e.toString();
                        });
            }
        }
    }

    @override
        void dispose() {
            _timer?.cancel();
            super.dispose();
        }

    @override
        Widget build(BuildContext context) {
            if (_errorMessage.isNotEmpty) {
                return Scaffold(body: Center(child: Text("Error: $_errorMessage")));
            }

            if (_sensorData == null) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final double methane = (_sensorData!['gas_methane_vol'] as num?)?.toDouble() ?? 0.0;
            final double pressure = (_sensorData!['pressure_kpa'] as num?)?.toDouble() ?? 0.0;
            final double phLevel = (_sensorData!['ph_level'] as num?)?.toDouble() ?? 0.0;
            final double temperature = (_sensorData!['temperature_c'] as num?)?.toDouble() ?? 0.0;

            return Scaffold(
                body: Container(
                    padding: EdgeInsets.all(32.0),
                    margin: EdgeInsets.fromLTRB(0, 160.0, 0, 0),
                    child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        children: [
                            CardRounded(
                                height: 40.0,
                                width: 160.0,
                                child: Text(
                                    "Kualitas CH4: \n$methane (%)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18.0),
                                )
                            ),
                            CardRounded(
                                height: 40.0,
                                width: 160.0,
                                child: Text(
                                    "Tekanan Gas : \n$pressure kPa",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18.0),
                                ),
                            ),
                            CardRounded(
                                height: 40.0,
                                width: 160.0,
                                child: Text(
                                    "Level pH Limbah: \n$phLevel",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18.0),
                                ),
                            ),
                            CardRounded(
                                height: 40.0,
                                width: 160.0,
                                child: Text(
                                    "Suhu Limbah: \n$temperature °C",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18.0),
                                ),
                            ),
                        ],
                    ),
                ),
            );
        }
}

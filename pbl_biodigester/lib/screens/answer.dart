import 'package:flutter/material.dart';
import 'package:pbl_biodigester/app/api_service.dart';
import 'package:pbl_biodigester/models/card_rounded.dart';

class AnswerScreen extends StatefulWidget {

    const AnswerScreen({super.key});

    @override
    State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
    final ApiService _api = ApiService();
    String _status = "";
    String _diagnosis = "";

    @override
    void initState() {
        super.initState();
        _initAI();
    }

    Future<void> _initAI() async {
        final result = await _api.fetchAiAnalysis();
        setState(() { 
            _status = result['ai_analysis']['status'];
            _diagnosis = result['ai_analysis']['diagnostic_reasoning']; // OPTIMAL, WARNING, CRITICAL
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    spacing: 32.0,
                    children: [
                        Container(
                            padding: EdgeInsets.all(16.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                    color: Colors.white70,
                                    width: 0.75,
                                )
                            ),
                            child: Text("STATUS BIODIGESTER : $_status")
                        ),
                        CardRounded(
                            width: double.infinity,
                            height: 500.0,
                            child: Column(
                                spacing: 12,
                                children: [
                                    Text("Hasil Diagnosis"),
                                    Text(_diagnosis),
                                ]
                            )
                        )
                    ],
                )
            ) 
            
        );
    }
}

import 'package:flutter/material.dart';
import 'package:pbl_biodigester/models/card_rounded.dart';

class AnswerScreen extends StatelessWidget {
    final String status;
    final String diagnosis;

    const AnswerScreen(this.status, this.diagnosis, {super.key});

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
                            child: Text("STATUS BIODIGESTER : $status")
                        ),
                        CardRounded(
                            width: double.infinity,
                            height: 500.0,
                            child: Column(
                                spacing: 12,
                                children: [
                                    Text("Hasil Diagnosis"),
                                    Text(diagnosis),
                                ]
                            )
                        )
                    ],
                )
            ) 
            
        );
    }
}

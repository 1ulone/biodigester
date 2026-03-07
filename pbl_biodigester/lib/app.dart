import 'package:flutter/material.dart';
import 'package:pbl_biodigester/screens/answer.dart';
import 'package:pbl_biodigester/screens/detail.dart';
import 'package:pbl_biodigester/screens/home.dart';

const homeScreen = '/';
const detailScreen = '/detail';
const answerScreen = '/answer';

class App extends StatelessWidget {
    const App({super.key});

    @override 
    Widget build(BuildContext context) {
        return MaterialApp(
            onGenerateRoute: routes(),
            theme: mainTheme(),
        );
    }

    ThemeData mainTheme() {
        return ThemeData(
            scaffoldBackgroundColor: const Color(0xFF0F0F0F),
            fontFamily: 'Montserrat',
            textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
                bodyLarge: TextStyle(color: Colors.white),
                bodySmall: TextStyle(color: Colors.white),
            )
        );
    }

    RouteFactory routes() {
        return (settings) {
            Widget screen;

            switch (settings.name) {
                case homeScreen:
                    screen = HomeScreen();
                    break;

                case detailScreen:
                    final args = settings.arguments as Map;
                    final int id = (args['id'] as num).toInt();
                    screen = DetailScreen(id);
                    break;

                case answerScreen:
                    final args = settings.arguments as Map;
                    final String status = (args['status'] as String);
                    final String diagnosis = (args['diagnosis'] as String);
                    screen = AnswerScreen(status, diagnosis);
                    break;

                default:
                    return MaterialPageRoute(
                            builder: (_) => Scaffold(
                                body: Center(child: Text('Route not found')),
                                ),
                            );
            }

            // return MaterialPageRoute(builder: (BuildContext context) => screen,);
            return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => screen,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                    opacity: animation,
                    child: child,
                    );
                },
            );
        };
    }
}

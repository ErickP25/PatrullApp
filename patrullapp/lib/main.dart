import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- Este archivo lo genera flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Importante para Web
  );
  runApp(const PatrullApp());
}

class PatrullApp extends StatelessWidget {
  const PatrullApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PatrullApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/inicio',
      routes: appRoutes,
      // Si tienes otras rutas con argumentos en el futuro, aquí va onGenerateRoute
    );
  }
}

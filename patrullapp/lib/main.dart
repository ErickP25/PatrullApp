import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pantallas/pantalla_detalle_reporte.dart';
import 'models/reporte.dart'; // Usa el modelo real

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      onGenerateRoute: (settings) {
        if (settings.name == '/detalle') {
          final reporte = settings.arguments as Reporte;
          return MaterialPageRoute(
            builder: (_) => PantallaDetalleReporte(reporte: reporte),
          );
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'routes.dart';
import 'models/reporte.dart'; // Asegúrate de importar tu modelo
import 'pantallas/pantalla_detalle_reporte.dart';



void main() {
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
      routes: appRoutes, // Solo rutas sin argumentos obligatorios
      onGenerateRoute: (settings) {
        // Ruta para detalle, pasando argumento reporte
        if (settings.name == '/detalle') {
          final reporte = settings.arguments as Reporte;
          return MaterialPageRoute(
            builder: (context) => PantallaDetalleReporte(reporte: reporte),
          );
        }
        // Si no encuentra la ruta, retorna null (irá a rutas por defecto)
        return null;
      },
    );
  }
}

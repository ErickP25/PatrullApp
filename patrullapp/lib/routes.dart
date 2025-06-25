import 'package:flutter/material.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_reporte.dart';
import 'pantallas/pantalla_alerta.dart';
import 'pantallas/pantalla_ingreso.dart';
import 'pantallas/pantalla_registro.dart';
import 'pantallas/pantalla_historial.dart';
import 'pantallas/pantalla_rutas_sereno.dart';
//import 'pantallas/pantalla_mapa_zonas.dart';
import 'pantallas/pantalla_perfil.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/inicio': (context) => const PantallaInicio(),
  '/ingreso': (context) => const PantallaIngreso(),
  '/registro': (context) => const PantallaRegistro(),
  '/reporte': (context) => const PantallaReporte(),
  '/alerta': (context) => const PantallaAlerta(),
  '/historial': (context) => const PantallaHistorial(),
  '/rutas_sereno': (context) => const PantallaRutasSereno(),
  //'/mapa_zonas': (context) => const PantallaExplorarZonas(),
  '/perfil': (context) => const PantallaPerfil(),
};

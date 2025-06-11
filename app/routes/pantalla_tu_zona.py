from flask import Blueprint, request, jsonify
from geoalchemy2.shape import from_shape
from shapely.geometry import Point
from sqlalchemy import func
from ..models.db import db
from ..models.zona import Zona
from ..models.reporte import Reporte
import json

tuzona_bp = Blueprint('tuzona', __name__)


@tuzona_bp.route('/api/ver_cantidad_incidentes', methods=['POST'])
def obtener_zona_por_ubicacion():
    data = request.get_json()
    lat = data.get('latitud')
    lon = data.get('longitud')

    if lat is None or lon is None:
        return jsonify({'error': 'Latitud y longitud requeridas'}), 400

    punto = f'POINT({lon} {lat})'

    zona_encontrada = db.session.query(Zona).filter(
        func.ST_Contains(Zona.geom, func.ST_SetSRID(func.ST_GeomFromText(punto), 4326))
    ).first()

    if zona_encontrada:
        zona_info = db.session.query(
            Zona.id_zona,
            Zona.nombre,
            Zona.cant_incidentes,
            func.ST_AsGeoJSON(Zona.geom).label('geom_geojson')
        ).filter(Zona.id_zona == zona_encontrada.id_zona).first()

        return jsonify({
            'type': 'Feature',
            'geometry': json.loads(zona_info.geom_geojson),
            'properties': {
                'id_zona': zona_info.id_zona,
                'nombre_zona': zona_info.nombre,
                'cant_incidentes': zona_info.cant_incidentes
            }
        })
    else:
        return jsonify({'mensaje': 'No se encontró zona para estas coordenadas'}), 404

@tuzona_bp.route('/api/ver_incidentes_en_zona', methods=['POST'])
def obtener_incidentes_por_ubicacion():
    data = request.get_json()
    lat = data.get('latitud')
    lon = data.get('longitud')

    if lat is None or lon is None:
        return jsonify({'error': 'Latitud y longitud requeridas'}), 400

    punto = f'POINT({lon} {lat})'

    zona = db.session.query(Zona).filter(
        func.ST_Contains(Zona.geom, func.ST_SetSRID(func.ST_GeomFromText(punto), 4326))
    ).first()

    if not zona:
        return jsonify({'mensaje': 'No se encontró zona para estas coordenadas'}), 404

    incidentes = db.session.query(Reporte).filter(Reporte.id_zona == zona.id_zona).all()

    # Construimos el FeatureCollection GeoJSON
    features = []
    for incidente in incidentes:
        if incidente.latitud is not None and incidente.longitud is not None:
            feature = {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [incidente.longitud, incidente.latitud]
                },
                "properties": {
                    "id_reporte": incidente.id_reporte,
                    "descripcion": incidente.descripcion
                }
            }
            features.append(feature)

    return jsonify({
        "type": "FeatureCollection",
        "features": features,
        "zona": {
            "id_zona": zona.id_zona,
            "nombre": zona.nombre
        }
    })
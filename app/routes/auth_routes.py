from functools import wraps
from flask import Blueprint, request, jsonify
import firebase_admin.auth as auth
from firebase_admin import exceptions
from firebase_admin import credentials, initialize_app

from ..models.vecino import Vecino
from ..models.db import db

# Firebase Admin
cred = credentials.Certificate("firebase_key.json")
initialize_app(cred)


def verificar_token(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]
        if not token:
            return jsonify({"error": "Token no proporcionado"}), 401
        try:
            decoded = auth.verify_id_token(token)
            request.user = decoded  # ahora puedes usar request.user en tus rutas
        except Exception as e:
            return jsonify({"error": str(e)}), 401
        return f(*args, **kwargs)

    return decorated


auth_routes = Blueprint('auth_routes', __name__)


@auth_routes.route('/api/register', methods=['POST'])
def register_user():
    data = request.get_json()

    required_fields = ['nombre', 'apellido', 'dni', 'telefono', 'direccion', 'password', 'confirm_password']
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Falta el campo {field}"}), 400

    if data['password'] != data['confirm_password']:
        return jsonify({"error": "Las contraseñas no coinciden"}), 400

    # Usamos el DNI como correo (puedes agregar @tudominio.com)
    email = data['dni']

    try:
        # Creamos el usuario en Firebase
        user_record = auth.create_user(
            email=email,
            password=data['password'],
            display_name=f"{data['nombre']} {data['apellido']}"
        )

        # Guardamos info adicional en PostgreSQL
        nuevo_vecino = Vecino(
            uid_firebase=user_record.uid,
            nombres=data['nombre'],
            apellidos=data['apellido'],
            dni=data['dni'],
            telefono=data['telefono'],
            direccion=data['direccion']
        )

        db.session.add(nuevo_vecino)
        db.session.commit()

        return jsonify({"message": "Usuario registrado exitosamente", "uid": user_record.uid}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 400

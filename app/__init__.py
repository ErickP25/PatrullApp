from flask import Flask
from flask_cors import CORS
from .config import Config
from .models.db import db
from .routes.incidente_routes import incidente_bp
from .routes.pantalla_tu_zona import tuzona_bp


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    CORS(app)

    # Base de datos
    db.init_app(app)


    # Registro de rutas

    app.register_blueprint(incidente_bp)
    app.register_blueprint(tuzona_bp)

    return app

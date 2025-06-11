from .db import db

class Ruta(db.Model):
    __tablename__ = 'ruta'

    id_ruta = db.Column(db.Integer, primary_key=True)
    id_zona = db.Column(db.Integer, db.ForeignKey('zona.id_zona'), nullable=False)

    latitud_inicio = db.Column(db.Float)
    longitud_inicio = db.Column(db.Float)
    latitud_fin = db.Column(db.Float)
    longitud_fin = db.Column(db.Float)

    # Relación con zona (opcional, útil si quieres acceder directamente)
    zona = db.relationship('Zona', backref='rutas', lazy=True)

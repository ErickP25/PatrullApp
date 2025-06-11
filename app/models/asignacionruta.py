from .db import db

class AsignacionRuta(db.Model):
    __tablename__ = 'asignacion_ruta'

    id_asignacion = db.Column(db.Integer, primary_key=True)
    id_ruta = db.Column(db.Integer, db.ForeignKey('ruta.id_ruta'), nullable=False)
    id_sereno = db.Column(db.Integer, db.ForeignKey('sereno.id_usuario'), nullable=False)

    fecha_asignacion = db.Column(db.Date, nullable=False)
    estado = db.Column(db.String(50), nullable=False)
    hora_inicio = db.Column(db.Time, nullable=False)
    hora_fin = db.Column(db.Time)
    cant_incidentes = db.Column(db.Integer, nullable=False)

    # Relaciones (opcionales pero recomendadas)
    ruta = db.relationship('Ruta', backref='asignaciones', lazy=True)
    sereno = db.relationship('Sereno', backref='asignaciones', lazy=True)

    db.relationship()
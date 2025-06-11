from .db import db
from .vecino import Vecino
from .sereno import Sereno
from .incidente import Incidente
from .zona import Zona
from .estadoreporte import EstadoReporte

class Reporte(db.Model):
    __tablename__ = 'reporte'

    id_reporte = db.Column(db.Integer, primary_key=True)
    id_vecino = db.Column(db.Integer, db.ForeignKey('vecino.id_usuario'), nullable=False)
    id_sereno = db.Column(db.Integer, db.ForeignKey('sereno.id_usuario'), nullable=False)
    id_incidente = db.Column(db.Integer, db.ForeignKey('incidente.id_incidente'), nullable=False)
    id_zona = db.Column(db.Integer, db.ForeignKey('zona.id_zona'), nullable=False)
    id_estado = db.Column(db.Integer, db.ForeignKey('estado_reporte.id_estado'), nullable=False)
    fecha = db.Column(db.Date, nullable=False)
    hora = db.Column(db.Time, nullable=False)
    direccion = db.Column(db.Text, nullable=False)
    longitud = db.Column(db.Float, nullable=False)
    latitud = db.Column(db.Float, nullable=False)
    descripcion = db.Column(db.Text, nullable=False)
    evidencia = db.Column(db.Boolean, nullable=False)
    emergencia = db.Column(db.Boolean, nullable=False)
    # Relaciones (opcional)
    vecino = db.relationship('Vecino', backref='reportes')
    sereno = db.relationship('Sereno', backref='reportes')
    incidente = db.relationship('Incidente', backref='reportes')
    zona = db.relationship('Zona', backref='reportes')
    estado = db.relationship('EstadoReporte', backref='reportes')

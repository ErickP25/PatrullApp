from .db import db
from .usuario import Usuario
from .estadosereno import EstadoSereno
from .municipalidad import Municipalidad
from .turno import Turno


class Sereno(db.Model):
    __tablename__ = 'sereno'

    id_usuario = db.Column(db.Integer, db.ForeignKey('usuario.id_usuario'), primary_key=True)
    id_municipalidad = db.Column(db.Integer, db.ForeignKey('municipalidad.id_municipalidad'), nullable=False)
    id_estado = db.Column(db.Integer, db.ForeignKey('estado_sereno.id_estado'), nullable=False)
    numero_placa = db.Column(db.String(20), nullable=False)
    id_turno = db.Column(db.Integer, db.ForeignKey('turno.id_turno'), nullable=False)

    # Relaciones (opcional)
    usuario = db.relationship('Usuario', backref=db.backref('sereno_info', uselist=False))
    municipalidad = db.relationship('Municipalidad', backref='serenos')
    estadosereno = db.relationship('EstadoSereno', backref='serenos')
    turno = db.relationship('Turno', backref='serenos')

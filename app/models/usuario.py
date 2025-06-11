from .db import db


class Usuario(db.Model):
    __tablename__ = 'usuario'

    id_usuario = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    apellido = db.Column(db.String(100), nullable=False)
    dni = db.Column(db.String(20), nullable=False)
    telefono = db.Column(db.String(20), nullable=False)
    contraseña = db.Column(db.Text, nullable=False)
    direccion = db.Column(db.Text, nullable=False)
    tipo_usuario = db.Column(db.Boolean, nullable=False)  # True = Sereno, False = Vecino
    uid_firebase = db.Column(db.Text, nullable=False)


from flask import Blueprint, request, jsonify
from ..models.incidente import Incidente
from ..models.db import db
from ..controllers.openai_utils import transcribir_audio, extraer_info_con_gpt
import datetime

incidente_bp = Blueprint('incidente', __name__)

@incidente_bp.route('/api/reportar_incidente', methods=['POST'])
def reportar_incidente():
    audio = request.files['audio']
    usuario_id = request.form['usuario_id']
    file_path = f"/tmp/{audio.filename}"
    audio.save(file_path)

    texto = transcribir_audio(file_path)
    resultado = extraer_info_con_gpt(texto)

    # Se asume que resultado es un JSON tipo:
    # {"tipo": "...", "distrito": "...", "lat": ..., "lon": ..., "descripcion": "..."}
    import json
    datos = json.loads(resultado)

    nuevo_incidente = Incidente(
        tipo=datos['tipo'],
        descripcion=datos['descripcion'],
        distrito=datos['distrito'],
        lat=datos.get('lat'),
        lon=datos.get('lon'),
        fecha=datetime.datetime.now(),
        usuario_id=usuario_id
    )

    db.session.add(nuevo_incidente)
    db.session.commit()

    return jsonify({'status': 'registrado'})
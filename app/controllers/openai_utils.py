import openai
import os

openai.api_key = os.getenv("OPENAI_API_KEY")

def transcribir_audio(file_path):
    with open(file_path, "rb") as f:
        transcript = openai.Audio.transcribe("whisper-1", f)
    return transcript["text"]


def extraer_info_con_gpt(texto):
    prompt = f"Extrae tipo de incidente, distrito, direccion, coordenadas si hay, y resumen del siguiente reporte:\n\n{texto}"
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2
    )
    return response.choices[0].message.content

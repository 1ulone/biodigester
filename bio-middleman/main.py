import os
import json
import requests
import firebase_admin
from firebase_admin import credentials, db
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone

# Initialize Firebase Realtime Database
cred = credentials.Certificate(os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "serviceAccountKey.json"))
firebase_admin.initialize_app(cred, {
    'databaseURL': os.environ.get("FIREBASE_DB_URL")
})

app = FastAPI()

GROQ_API_KEY = os.environ.get("GROQ_API_KEY")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
CHAT_MODEL = "llama-3.3-70b-versatile"

class BiodigesterData(BaseModel):
    gas_methane_vol: float
    pressure_kpa: float
    temperature_c: float
    ph_level: float

@app.post("/analyze")
async def analyze_bot(data: BiodigesterData):
    if not GROQ_API_KEY:
        raise HTTPException(500, "GROQ_API_KEY is missing")

    raw_data = {
        "sensor_ch4": data.gas_methane_vol,
        "sensor_pressure": data.pressure_kpa,
        "sensor_temperature": data.temperature_c,
        "sensor_ph": data.ph_level
    }

    context = f"""
    Analyze this biodigester sensor data:
    Methane: {data.gas_methane_vol}%
    Pressure: {data.pressure_kpa} kPa
    Temperature: {data.temperature_c} °C
    pH Level: {data.ph_level}
    """

    payload = {
        "model": CHAT_MODEL,
        "messages": [
            {
                "role": "system", 
                "content": (
                    "Anda adalah AI diagnostik biodigester. "
                    "Gunakan Bahasa Indonesia untuk semua nilai teks. "
                    "Selalu kembalikan objek JSON valid dengan kunci: "
                    "'status' (OPTIMAL, WARNING, CRITICAL), "
                    "'primary_anomaly', dan "
                    "'diagnostic_reasoning'. "
                    "Pada kunci 'diagnostic_reasoning', berikan penjelasan mendalam mengenai kondisi sensor "
                    "dan berikan solusi praktis yang harus dilakukan pengguna."
                )
            },
            {
                "role": "user", 
                "content": context
            }
        ],
        "temperature": 0.1,
        "response_format": {"type": "json_object"}
    }

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    resp = requests.post(GROQ_URL, json=payload, headers=headers, timeout=30)

    try:
        resp_data = resp.json()
    except Exception:
        raise HTTPException(500, f"Groq returned non-JSON: {resp.text}")

    if resp.status_code != 200:
        raise HTTPException(500, f"Groq Error: {resp_data}")

    reply = resp_data["choices"][0]["message"]["content"]

    try:
        analysis_json = json.loads(reply)
        final_payload = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "input_data": data.model_dump(),
            "ai_analysis": analysis_json
        }
        
        # Push to Realtime Database
        ref = db.reference("biodigester_logs")
        ref.push(final_payload)
        
        return final_payload
    except json.JSONDecodeError:
        return {"error": "Failed to parse AI output", "raw": reply}

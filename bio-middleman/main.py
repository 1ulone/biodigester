import os
import json
import requests
import asyncio
import traceback
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime, timezone
from fastapi_mqtt import FastMQTT, MQTTConfig
from database import SessionLocal, SensorReading
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Add this block after app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allows all headers
)

# 1. MQTT Configuration
mqtt_config = MQTTConfig(
    host="mosquitto",
    port=1883,
    keepalive=60
)
mqtt = FastMQTT(config=mqtt_config)
mqtt.init_app(app)

# Global for Live Polling
latest_mqtt_data = {"status": "waiting for data"}

# 2. AI Configuration (Groq)
GROQ_API_KEY = os.environ.get("GROQ_API_KEY")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
CHAT_MODEL = "openai/gpt-oss-120b"

class BiodigesterData(BaseModel):
    gas_methane_vol: float
    pressure_kpa: float
    temperature_c: float
    ph_level: float
    fuel_left: float  # Added per your requirement

# 3. MQTT Callbacks & Database Logging
@mqtt.on_connect()
def connect(client, flags, rc, properties):
    # Added the leading slash to match your previous setup
    mqtt.client.subscribe("/biodigester/sensors")
    print("Connected to MQTT Broker and subscribed to /biodigester/sensors")

@mqtt.on_message()
async def message(client, topic, payload, qos, properties):
    global latest_mqtt_data
    # Print the raw payload to the docker logs
    raw_payload = payload.decode()
    print(f"Received payload: {raw_payload}")
    
    try:
        data = json.loads(raw_payload)
        latest_mqtt_data = data
        
        db = SessionLocal()
        new_reading = SensorReading(
            methane=data.get("gas_methane_vol"),
            pressure=data.get("pressure_kpa"),
            temperature=data.get("temperature_c"),
            ph=data.get("ph_level"),
            fuel_left=data.get("fuel_left")
        )
        db.add(new_reading)
        db.commit()
        db.close()
        print("Data saved to PostgreSQL successfully.")
    except Exception as e:
        print(f"Error processing message: {e}")

# 4. Endpoints
@app.get("/status")
def read_sensor_data():
    """Live status for Flutter polling"""
    return latest_mqtt_data

@app.post("/analyze")
async def analyze_bot():
    import traceback
    try:
        if not GROQ_API_KEY:
            return {"error": "GROQ_API_KEY is missing"}

        db = SessionLocal()
        last_record = db.query(SensorReading).order_by(SensorReading.timestamp.desc()).first()
        db.close()

        if not last_record:
            return {"error": "No data available in database"}

        context = f"""
        Analyze this biodigester sensor data:
        Methane: {last_record.methane}%
        Pressure: {last_record.pressure} kPa
        Temperature: {last_record.temperature} °C
        pH Level: {last_record.ph}
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
                        "'diagnostic_reasoning'."
                    )
                },
                {"role": "user", "content": context}
            ],
            "temperature": 0.1,
            "response_format": {"type": "json_object"}
        }

        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json"
        }

        resp = requests.post(GROQ_URL, json=payload, headers=headers, timeout=30)
        
        if resp.status_code != 200:
            return {"error": f"Groq Error: {resp.text}"}

        reply = resp.json()["choices"][0]["message"]["content"]

        return {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "ai_analysis": json.loads(reply)
        }
    except Exception as e:
        error_trace = traceback.format_exc()
        print(f"CRITICAL ERROR: {error_trace}")
        return {"detail": str(e), "traceback": error_trace.splitlines()}

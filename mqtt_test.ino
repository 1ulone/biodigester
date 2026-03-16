#include <WiFi.h>
#include <PubSubClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>


const char* ssid = "ULWIFI";
const char* password = "ireng5656";

const char* mqtt_server = "10.93.55.46"; 
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

const int PIN_PRESSURE = 32; 
const int PIN_TEMP = 13;
const int PH_PIN = 33;
const int PIN_METHANE_VOUT = 34;
const int PIN_METHANE_VREF = 35;
const float VS = 5.0; 
const float VOLTAGE_RANGE = 3.3;
const float ADC_RESOLUTION = 4095.0;
const float DRUM_VOLUME_LITERS = 200.0; 
const float V_HEADSPACE = DRUM_VOLUME_LITERS * 0.25;

OneWire oneWire(PIN_TEMP);
DallasTemperature sensors(&oneWire);

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected.");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection to ");
    Serial.print(mqtt_server);
    Serial.print("...");
    
    if (client.connect("ESP32_Biodigester")) {
      Serial.println(" connected");
    } else {
      Serial.print(" failed, rc=");
      Serial.print(client.state());
      Serial.println(" - retrying in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  analogReadResolution(12);
  
  pinMode(PIN_METHANE_VOUT, INPUT);
  pinMode(PIN_METHANE_VREF, INPUT);
  
  sensors.begin();
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  int rawADC = analogRead(PIN_PRESSURE);
  float vMeasured = (rawADC / 4095.0) * 3.3;
  float pressureKPa = (((vMeasured / VS) - 0.04) / 0.0012858) + 28.96;
  if (pressureKPa < 0) pressureKPa = 0;

  sensors.requestTemperatures(); 
  float tempC = sensors.getTempCByIndex(0);
  

  int rawVout = analogRead(PIN_METHANE_VOUT);
  int rawVref = analogRead(PIN_METHANE_VREF);
  
  float voutAdc = (rawVout / 4095.0) * 3.3;
  float vrefAdc = (rawVref / 4095.0) * 3.3;
  
  float actualVout = voutAdc * 1.702127;
  float actualVref = vrefAdc * 1.702127;

  float gasMethaneVol = (actualVout / 5.0) * 100.0; 

  int rawPH = analogRead(PH_PIN);
  float phVoltage = (rawPH / ADC_RESOLUTION) * VOLTAGE_RANGE;
  float phLevel = 3.5 * phVoltage; 

  float fuel_left_liters = V_HEADSPACE * (pressureKPa / 101.325) * (273.15 / (273.15 + tempC)) * (gasMethaneVol / 100.0);

  String payload = "{";
  payload += "\"gas_methane_vol\": " + String(gasMethaneVol, 2) + ", ";
  payload += "\"pressure_kpa\": " + String(pressureKPa, 2) + ", ";
  payload += "\"temperature_c\": " + String(tempC, 2) + ", ";
  payload += "\"ph_level\": " + String(phLevel, 2) + ", ";
  payload += "\"fuel_left\": " + String(fuel_left_liters);
  payload += "}";

  client.publish("/biodigester/sensors", payload.c_str());
/*
  Serial.print("Raw VOUT: ");
  Serial.print(rawVout);
  Serial.print(" | Raw VREF: ");
  Serial.print(rawVref);
  Serial.print(" | Actual VOUT: ");
  Serial.print(actualVout);
  Serial.print("V | Actual VREF: ");
  Serial.print(actualVref);
  Serial.println("V");
*/

  Serial.print("Published: ");
  Serial.println(payload);

  delay(2000);
}
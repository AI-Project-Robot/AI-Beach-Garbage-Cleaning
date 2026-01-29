#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>

RF24 radio(D2, D8);  // CE, CSN
const byte address[6] = "00002";

// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// API endpoint
const char* apiUrl = "http://127.0.0.1:5000/api/emit-signal";

void setup() {
  Serial.begin(9600);
  delay(100);

  // Connect to WiFi
  Serial.println();
  Serial.print("Connecting to WiFi");
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println();
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Initialize radio
  radio.begin();
  radio.setPALevel(RF24_PA_HIGH);   // PA/LNA recommended
  radio.setDataRate(RF24_250KBPS);  // better range
  radio.openWritingPipe(address);
  radio.stopListening();
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;
    
    http.begin(client, apiUrl);
    http.addHeader("Content-Type", "application/json");
    
    String jsonBody = "{\"receiver\":\"T2\"}";
    int httpCode = http.POST(jsonBody);
    
    if (httpCode > 0) {
      String payload = http.getString();
      int valueToSend = payload.toInt();
      
      Serial.print("API Response: ");
      Serial.println(valueToSend);
      
      if (valueToSend > 0) {
        bool sent = radio.write(&valueToSend, sizeof(valueToSend));
        
        if (sent) {
          Serial.print("Transmitter 2 Sent: ");
          Serial.println(valueToSend);
        } else {
          Serial.println("Transmitter 2 Send failed");
        }
      } else {
        Serial.println("Value not > 0, skipping transmission");
      }
    } else {
      Serial.print("HTTP GET failed, error: ");
      Serial.println(http.errorToString(httpCode));
    }
    
    http.end();
  } else {
    Serial.println("WiFi disconnected");
  }
  
  delay(1000);  // Poll every second
}

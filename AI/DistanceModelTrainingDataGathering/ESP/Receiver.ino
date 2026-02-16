#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>

RF24 radio(D2, D8);  // CE, CSN
const byte address1[6] = "00001";
const byte address2[6] = "00002";

// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// API base URL
const char* apiBaseUrl = "http://127.0.0.1:5000/api/receive-signal/";

int receivedNumber;

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
  radio.setPALevel(RF24_PA_HIGH);
  radio.setDataRate(RF24_250KBPS);
  radio.openReadingPipe(0, address1);  // Pipe 0 for transmitter 1
  radio.openReadingPipe(1, address2);  // Pipe 1 for transmitter 2
  radio.startListening();
}

void loop() {
  uint8_t pipeNum;
  
  if (radio.available(&pipeNum)) {
    radio.read(&receivedNumber, sizeof(receivedNumber));
    Serial.print("Received from Transmitter ");
    Serial.print(pipeNum + 1);
    Serial.print(": ");
    Serial.println(receivedNumber);
    
    // Call API with received signal
    if (WiFi.status() == WL_CONNECTED) {
      WiFiClient client;
      HTTPClient http;
      
      // Build API URL with signal_id
      String apiUrl = String(apiBaseUrl) + String(receivedNumber);
      
      http.begin(client, apiUrl);
      http.addHeader("Content-Type", "application/json");
      
      // Build JSON body based on pipe number
      String jsonBody;
      if (pipeNum == 0) {
        jsonBody = "{\"receiver\":\"T1\"}";
      } else {
        jsonBody = "{\"receiver\":\"T2\"}";
      }
      
      int httpCode = http.POST(jsonBody);
      
      if (httpCode > 0) {
        String response = http.getString();
        Serial.print("API Response: ");
        Serial.println(response);
      } else {
        Serial.print("HTTP POST failed, error: ");
        Serial.println(http.errorToString(httpCode));
      }
      
      http.end();
    } else {
      Serial.println("WiFi disconnected");
    }
  }
}

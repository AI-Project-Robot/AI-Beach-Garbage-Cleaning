import network
import time
from machine import Pin


ID = "TRANSMITTER_1" 
WIFI_CHANNEL = 1
TX_POWER = 8 

led = Pin(2, Pin.OUT)

ap = network.WLAN(network.AP_IF)
ap.active(True)

ap.config(txpower=TX_POWER) # Reduced Multipath Interference

#configure the access point 
ap.config(
    essid=ID,  
    channel=WIFI_CHANNEL,
    authmode=network.AUTH_WPA_WPA2_PSK
)

while not ap.active():
    pass

print("Transmitter ON:", ID)
print(ap.ifconfig())

while True:
    led.value(not led.value())
    time.sleep(0.2)  # Blink every 200 ms
#include <Wire.h>

void setup() {
  // Removed setSDA and setSCL. Let Teensy 4.0 use its Wire1 defaults (16 & 17)
  Wire.begin();
  
  Serial.begin(115200);
  while (!Serial); 
  Serial.println("\nI2C SPAM Scanner is running on Wire1...");
}

void loop() {
  byte error;
  
  // We will just spam address 0x39 (The Spectral Sensor) 
  // over and over again as fast as possible.
  Wire.beginTransmission(0x39);
  error = Wire.endTransmission();

  if (error == 0) {
    Serial.println("FOUND IT!");
    delay(1000); // Pause if we actually find it
  }
  
  // No 5-second delay. Spam the pins constantly!
  delay(10); 
}
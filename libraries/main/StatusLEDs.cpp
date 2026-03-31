#include "StatusLEDs.h"

StatusLEDs::StatusLEDs() {
    lastExecutionTime = 0;
    lastGreenToggle = 0;
    lastWhiteToggle = 0;
    greenState = false;
    whiteState = false;
}

void StatusLEDs::init(int redPin, int greenPin, int whitePin) {
    rPin = redPin;
    gPin = greenPin;
    wPin = whitePin;
    
    pinMode(rPin, OUTPUT);
    pinMode(gPin, OUTPUT);
    pinMode(wPin, OUTPUT);
    
    digitalWrite(rPin, LOW);
    digitalWrite(gPin, LOW);
    digitalWrite(wPin, LOW);
}

void StatusLEDs::update(uint32_t currentTime, bool hasError, bool isDelayPhase, uint32_t timeUntilStart) {
    
    // RED: Error indicator
    if (hasError) {
        digitalWrite(rPin, HIGH);
    } else {
        digitalWrite(rPin, LOW);
    }

    // GREEN: Heartbeat
    if (currentTime - lastGreenToggle >= 500) {
        greenState = !greenState;
        digitalWrite(gPin, greenState);
        lastGreenToggle = currentTime;
    }

    // WHITE: Deployment indicator
    if (isDelayPhase) {
        if (timeUntilStart <= 10000) { 
            // Last 10 seconds: Fast strobe (toggle every 125ms)
            if (currentTime - lastWhiteToggle >= 125) {
                whiteState = !whiteState;
                digitalWrite(wPin, whiteState);
                lastWhiteToggle = currentTime;
            }
        } else { 
            // First 1m 50s: Off
            digitalWrite(wPin, LOW);
            whiteState = false;
        }
    } else { 
        // Delay is over, robot is active: Solid White
        digitalWrite(wPin, HIGH);
    }
}
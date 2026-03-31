#ifndef STATUS_LEDS_H
#define STATUS_LEDS_H

#include <Arduino.h>

class StatusLEDs {
public:
    StatusLEDs();

	// takes in pin numbers to initialize
    void init(int redPin, int greenPin, int whitePin);

    // Update called from main loop
    void update(uint32_t currentTime, bool hasError, bool isDelayPhase, uint32_t timeUntilStart);

    uint32_t lastExecutionTime;

private:
    int rPin;
    int gPin;
    int wPin;
    
    uint32_t lastGreenToggle;
    uint32_t lastWhiteToggle;
    
    bool greenState;
    bool whiteState;
};

#endif // STATUS_LEDS_H
#include "SensorThermistor.h"

// Define the names and types for the python script to unpack
SensorThermistor::SensorThermistor() : 
    DataSource("Therm_Raw", "float") 
{
    lastExecutionTime = -1;
    rawValue = 0;
	errorStatus = false; // Initialize to no error
}

void SensorThermistor::init(int analogPin) {
    pin = analogPin;
    pinMode(pin, INPUT);
}

void SensorThermistor::read(void) {
    // read the raw analog value
    rawValue = analogRead(pin);
	if (rawValue <= 5 || rawValue >= 1018) { // if railing out, error.
        errorStatus = true;
        return;
    } else {
        errorStatus = false;
    }
}

String SensorThermistor::printState(void) {
	if (errorStatus) {
        return "Therm: ERROR (Raw: " + String(rawValue) + ")";
    }
	else{
    	return "Therm rawValue: " + String(rawValue);
	}
}

size_t SensorThermistor::writeDataBytes(unsigned char * buffer, size_t idx) {
    // write the 16-bit raw integer
    uint16_t * raw_slot = (uint16_t *) &buffer[idx];
    raw_slot[0] = rawValue;
    idx += sizeof(uint16_t); // Move index forward by 2 bytes
    
    // Return the updated index so the next sensor writes to the correct spot
    return idx; 
}
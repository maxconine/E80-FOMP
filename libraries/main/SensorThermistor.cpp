#include "SensorThermistor.h"

// Define the names and types for the python script to unpack
SensorThermistor::SensorThermistor() : 
    DataSource("Therm_Raw,Therm_Temp", "float,float")
{
    lastExecutionTime = -1;
    rawValue = 0;
	temperature = 0;
	errorStatus = false; // Initialize to no error
}

void SensorThermistor::init(int analogPin) {
    pin = analogPin;
    pinMode(pin, INPUT);
}

void SensorThermistor::read(void) {
    // 1. Read the raw analog voltage
    // Note: Use 1023.0 to ensure floating-point division
	analogRead(pin); // Dummy read
    rawValue = analogRead(pin) * VCC / 1023.0;

    // 2. Error Checking
    // Since rawValue is now in Volts (0 to 3.3), we adjust the rail checks
    if (rawValue <= 0.001 || rawValue >= 3.33) { 
        errorStatus = true;
        return;
    } else {
        errorStatus = false;
    }

	// linear fit
	temperature = -5.94* rawValue + 21.2;

}

String SensorThermistor::printState(void) {
    if (errorStatus) {
        return "Therm: ERROR (Raw Volts: " + String(rawValue, 4) + "V)";
    }
    else {
        // Prints Temperature and Raw Voltage, limited to 2 decimal places for cleaner output
        return "Therm Temp: " + String(temperature, 2) + " (Raw: " + String(rawValue, 2) + "V)";
    }
}

size_t SensorThermistor::writeDataBytes(unsigned char * buffer, size_t idx) {
    float * data_slot = (float *) &buffer[idx];
    
    data_slot[0] = (float)rawValue;    // Index: idx to idx+3
    data_slot[1] = (float)temperature; // Index: idx+4 to idx+7
    
    // Return updated index (moved 8 bytes forward)
    return idx + (2 * sizeof(float)); 
}
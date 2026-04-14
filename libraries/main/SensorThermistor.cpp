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
    // 1. Read the raw analog voltage
    // Note: Use 1023.0 to ensure floating-point division
    rawValue = analogRead(pin) * VCC / 1023.0;

    // 2. Error Checking
    // Since rawValue is now in Volts (0 to 3.3), we adjust the rail checks
    if (rawValue <= 0.01 || rawValue >= 3.28) { 
        errorStatus = true;
        return;
    } else {
        errorStatus = false;
    }

    // 3. Convert Voltage to Resistance (R)
    // ASSUMPTION: Thermistor is connected between Analog Pin and Ground (Pull-up configuration)
    // If your thermistor is connected between Analog Pin and VCC, use: 
    // resistance = R_SERIES * (rawValue / (VCC - rawValue));
    resistance = R_SERIES * ((VCC / rawValue) - 1.0);

    // 4. Apply Steinhart-Hart Equation
    // In C++, log() computes the natural logarithm (ln)
    float logR = log(resistance); 
    
    // Calculate the temperature based on your specific polynomial fit
    temperature = 1.0 / (A_COEF + 
                         B_COEF * logR + 
                         C_COEF * pow(logR, 2) + 
                         D_COEF * pow(logR, 3));

    // NOTE: Standard Steinhart-Hart equations yield temperature in Kelvin. 
    // If your specific coefficients were generated to output Kelvin, uncomment the line below:
    // temperature = temperature - 273.15; 
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
    // write the 16-bit raw integer
    uint16_t * raw_slot = (uint16_t *) &buffer[idx];
    raw_slot[0] = rawValue;
    idx += sizeof(uint16_t); // Move index forward by 2 bytes
    
    // Return the updated index so the next sensor writes to the correct spot
    return idx; 
}
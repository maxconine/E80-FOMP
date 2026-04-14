#ifndef SENSOR_THERMISTOR_H
#define SENSOR_THERMISTOR_H

#include <Arduino.h>
#include "DataSource.h"
// Define your circuit parameters
const float VCC = 3.3;
const float R_SERIES = 10000.0; // Replace with your actual series resistor value in Ohms

// Define your Steinhart-Hart coefficients
const float A_COEF = -554;
const float B_COEF = 175.2;
const float C_COEF = -20.64;
const float D_COEF = 19.4;

class SensorThermistor : public DataSource {
public:
    SensorThermistor();

    // Pass in the analog pin the thermistor is connected to
    void init(int analogPin); 
    void read(void); // Updates state in the main loop
    
    uint32_t lastExecutionTime;

    // Required by E80 Printer and Logger
    String printState(void); 
    size_t writeDataBytes(unsigned char * buffer, size_t idx);

    // Data storage
    float rawValue;
    float temperature;
	bool errorStatus;
	float resistance;

private:
    int pin;
    
};

#endif // SENSOR_THERMISTOR_H
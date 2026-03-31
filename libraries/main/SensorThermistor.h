#ifndef SENSOR_THERMISTOR_H
#define SENSOR_THERMISTOR_H

#include <Arduino.h>
#include "DataSource.h"

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
    uint16_t rawValue;
    float temperatureC;
	bool errorStatus;


private:
    int pin;
    
};

#endif // SENSOR_THERMISTOR_H
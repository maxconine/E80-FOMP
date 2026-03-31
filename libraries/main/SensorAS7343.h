#ifndef SENSOR_AS7343_H
#define SENSOR_AS7343_H

#include <Arduino.h>
#include <SparkFun_AS7343.h>
#include "DataSource.h"

class SensorAS7343 : public DataSource {
public:
    SensorAS7343();

    void init(void);
    void read(void);
    uint32_t lastExecutionTime;

    String printState(void); 
    size_t writeDataBytes(unsigned char * buffer, size_t idx);

    // Array to hold the 18 channels of spectral data
    uint16_t myData[ksfAS7343NumChannels]; 
    int channelsRead;
	bool errorStatus;

private:
    SfeAS7343ArdI2C sensor;
};

#endif // SENSOR_AS7343_H
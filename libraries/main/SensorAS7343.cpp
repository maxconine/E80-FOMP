#include "SensorAS7343.h"

// The E80 Python log parser reads these strings to know how to unpack the SD card bytes.
// Since we are saving 18 uint16_t variables, we must declare 18 names and 18 "uint16_t" types.
SensorAS7343::SensorAS7343() : 
    DataSource("AS7343_CH0,AS7343_CH1,AS7343_CH2,AS7343_CH3,AS7343_CH4,AS7343_CH5,AS7343_CH6,AS7343_CH7,AS7343_CH8,AS7343_CH9,AS7343_CH10,AS7343_CH11,AS7343_CH12,AS7343_CH13,AS7343_CH14,AS7343_CH15,AS7343_CH16,AS7343_CH17",
               "uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t,uint16_t") 
{
    lastExecutionTime = -1;
    channelsRead = 0;
    // Initialize array to 0
    for(int i = 0; i < ksfAS7343NumChannels; i++) {
        myData[i] = 0;
    }
}

void SensorAS7343::init(void) {
    Wire.begin();
	errorStatus = false;
    
    if (sensor.begin() == false) {
		errorStatus = true;
        Serial.println("AS7343 failed to begin. Check wiring!");
    } else {
        sensor.powerOn();
        sensor.setAutoSmux(AUTOSMUX_18_CHANNELS);
        sensor.enableSpectralMeasurement();
        
        // Turn LED off
        sensor.setLedDrive(0); // (0 = 4mA). 
        sensor.ledOff(); 
    }
}

void SensorAS7343::read(void) {
    // Read the data registers from the sensor
    if (sensor.readSpectraDataFromSensor() == true) {
        channelsRead = sensor.getData(myData);
    }
}

String SensorAS7343::printState(void) {
	if (errorStatus){
		return "AS7343 Spectral Sensor: ERROR";
	}
	uint16_t red = 0, green = 0, blue = 0, nir = 0;
	if (sensor.readSpectraDataFromSensor()) {
        red   = sensor.getRed();
        green = sensor.getGreen();
        blue  = sensor.getBlue();
        nir   = sensor.getNIR();
	} else {
        errorStatus = true; // Flag error if reading fails
    }
	String output = "R: " + String(red) + 
						" G: " + String(green) + 
						" B: " + String(blue) + 
						" NIR: " + String(nir);
	return output;
}

size_t SensorAS7343::writeDataBytes(unsigned char * buffer, size_t idx) {
    // Cast the buffer starting at 'idx' to a 16-bit integer pointer
    uint16_t * data_slot = (uint16_t *) &buffer[idx];
    
    // Write all 18 channels directly into the SD card buffer memory
    for (int i = 0; i < ksfAS7343NumChannels; i++) {
        data_slot[i] = myData[i];
    }
    
    // Update the buffer index (we wrote 18 channels * 2 bytes each = 36 bytes)
    return idx + (ksfAS7343NumChannels * sizeof(uint16_t));
}
#ifndef __ERRORFLAGSAMPLER_h__
#define __ERRORFLAGSAMPLER_h__

#include <Arduino.h>
#include "DataSource.h"
#include "Pinouts.h"

/*
 * ErrorFlagSampler implements SD logging for the three digital 
 * channels hardwired to the error flag output of each H-bridge
 */

#define NUM_FLAGS 3

class ErrorFlagSampler : public DataSource
{
public:
  ErrorFlagSampler(void);

  void init(void);

  // Managing state
  bool flagStates[NUM_FLAGS];
  
  // Takes the states calculated in the main loop
  void updateStates(bool Pressure_State, bool Thermistor_State, bool Spectral_State);
  String printStates(void);

  // Write out
  size_t writeDataBytes(unsigned char * buffer, size_t idx);

  int lastExecutionTime = -1;
};

#endif
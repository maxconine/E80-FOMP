#include "ErrorFlagSampler.h"
#include <math.h>
#include "Printer.h"

extern Printer printer;

ErrorFlagSampler::ErrorFlagSampler(void) 
  // column names for the SD card log
  : DataSource("Err_Pressure,Err_Thermistor,Err_Spectral","bool,bool,bool") 
{}

void ErrorFlagSampler::init(void){}

void ErrorFlagSampler::updateStates(bool Pressure_State, bool Thermistor_State, bool Spectral_State)
{
  // 1 means error detected
  flagStates[0] = Pressure_State;
  flagStates[1] = Thermistor_State;
  flagStates[2] = Spectral_State;
}

String ErrorFlagSampler::printStates(void)
{
  // Updated names for the real-time Serial monitor
  String errorNamesList [NUM_FLAGS] = {"Pressure_Err: ", " Thermistor_Err: ", " Spectral_Err: "};
  String printString = "Errors -> ";
  
  for (int i = 0; i < NUM_FLAGS; i++) {
    printString += errorNamesList[i];
    printString += String(flagStates[i]);
  }
  
  return printString;
}

size_t ErrorFlagSampler::writeDataBytes(unsigned char * buffer, size_t idx)
{
  bool * data_slot = (bool *) &buffer[idx];
  for (int i = 0; i < NUM_FLAGS; i++) {
    data_slot[i] = flagStates[i];
  }
  return idx + NUM_FLAGS * sizeof(bool);
}
/********
Default E80 Code
Current Author:
    Wilson Ives (wives@g.hmc.edu) '20 (contributed in 2018)
Previous Contributors:
    Christopher McElroy (cmcelroy@g.hmc.edu) '19 (contributed in 2017)  
    Josephine Wong (jowong@hmc.edu) '18 (contributed in 2016)
    Apoorva Sharma (asharma@hmc.edu) '17 (contributed in 2016)                    
*/

/* Libraries */

// general
#include <Arduino.h>
#include <Wire.h>
#include <Pinouts.h>

// E80-specific
#include <SensorIMU.h>
#include <MotorDriver.h>
#include <Logger.h>
#include <Printer.h>


/* Global Variables */

// period in ms of logger and printer
#define LOOP_PERIOD 100

// Motors
MotorDriver motorDriver;

// IMU
SensorIMU imu;

// Logger
Logger logger;
bool keepLogging = true;

// Printer
Printer printer;

// loop start recorder
int loopStartTime;

void setup() {
  printer.init();

  /* Initialize the Logger */
  logger.include(&imu);
  logger.include(&motorDriver);
  logger.init();

  /* Initialise the sensors */
  imu.init();

  /* Initialize motor pins */
  motorDriver.init();

  /* Keep track of time */
  printer.printMessage("Starting main loop",10);
  loopStartTime = millis();
}


void loop() {

  int currentTime = millis() - loopStartTime;
  
  ///////////  Don't change code above here! ////////////////////
  // write code here to make the robot fire its motors in the sequence specified in the lab manual 
  // the currentTime variable contains the number of ms since the robot was turned on 
  // The motorDriver.drive function takes in 3 inputs arguments motorA_power, motorB_power, motorC_power: 
  //       void motorDriver.drive(int motorA_power,int motorB_power,int motorC_power); 
  // the value of motorX_power can range from -255 to 255, and sets the PWM applied to the motor 
  // The following example will turn on motor B for four seconds between seconds 4 and 8 

  // Motor A is right side, Motor B is down side, Motor C is left looking at robot from behind
  
  // Wait 20 seconds for us to close the box and place the robot in the water
  int initPlacementTime = 90000;

  // Go for 4 seconds down at 70% speed
  int downTime = 10000;
  int downSpeed = 0.9 * 255;

  // Go for 10 seconds across
  int acrossTime = 10000;
  int acrossSpeedLeft = 0.8 * 255;
  int acrossSpeedRight = 0.7 * 255;

  // Go for 8 seconds back up at 70 % speed
  int upTime = 15000;
  int upSpeed = 1 * -255;

  if ((currentTime > initPlacementTime) && (currentTime < (initPlacementTime + downTime))) {
    motorDriver.drive(0,downSpeed,0);
  } else {
    motorDriver.drive(0,0,0);
  }

  if ((currentTime > (initPlacementTime + downTime)) && (currentTime < (initPlacementTime + downTime + acrossTime))) {
    motorDriver.drive(acrossSpeedRight,0.3*255,acrossSpeedLeft);
  } else {
    motorDriver.drive(0,0,0);
  }

  if ((currentTime > (initPlacementTime + downTime + acrossTime)) && (currentTime < (initPlacementTime + downTime + acrossTime + upTime))) {
    motorDriver.drive(0,upSpeed,0);
  } else {
    motorDriver.drive(0,0,0);
  }

  // DONT CHANGE CODE BELOW THIS LINE 
  // --------------------------------------------------------------------------

  
  if ( currentTime-printer.lastExecutionTime > LOOP_PERIOD ) {
    printer.lastExecutionTime = currentTime;
    printer.printValue(0,imu.printAccels());
    printer.printValue(1,imu.printRollPitchHeading());
    printer.printValue(2,motorDriver.printState());
    printer.printToSerial();  // To stop printing, just comment this line out
  }

  if ( currentTime-imu.lastExecutionTime > LOOP_PERIOD ) {
    imu.lastExecutionTime = currentTime;
    imu.read(); // this is a sequence of blocking I2C read calls
  }

  if ( currentTime-logger.lastExecutionTime > LOOP_PERIOD && logger.keepLogging) {
    logger.lastExecutionTime = currentTime;
    logger.log();
  }

}

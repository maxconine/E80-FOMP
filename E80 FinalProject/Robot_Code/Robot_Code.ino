// E80 Robot Code
// Max, Freja, Octavia, Pierce 

#include <Arduino.h>
#include <Wire.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include <Pinouts.h>
#include <TimingOffsets.h>
#include <SensorIMU.h>
#include <ZStateEstimator.h>
#include <ADCSampler.h>
#include <ErrorFlagSampler.h>
#include <ButtonSampler.h> 
#include <MotorDriver.h>
#include <Logger.h>
#include <Printer.h>
#include <DepthControl.h>
#include <SensorAS7343.h>
#include <StatusLEDs.h>
#include <SensorThermistor.h>

// LED Pins  			// TODO CHANGE THESE
#define RED_LED_PIN   20
#define GREEN_LED_PIN 21
#define WHITE_LED_PIN 22
#define THERMISTOR_PIN 15 

StatusLEDs status_leds;

/////////////////////////* Global Variables *////////////////////////

MotorDriver motor_driver;
ZStateEstimator z_state_estimator;
DepthControl depth_control;
ADCSampler adc;
ErrorFlagSampler ef;
ButtonSampler button_sampler;
SensorIMU imu;
SensorAS7343 spectral_sensor;
Logger logger;
Printer printer;
SensorThermistor thermistor;

// loop start recorder
uint32_t loopStartTime;
uint32_t currentTime;
volatile bool EF_States[NUM_FLAGS] = {1,1,1};

const uint32_t DEPLOY_DELAY_MS = 120000; // 2 minutes in milliseconds
uint32_t deploymentStartTime = 0;

////////////////////////* Setup *////////////////////////////////

void setup() {
  
  logger.include(&imu);
  logger.include(&z_state_estimator);
  logger.include(&depth_control);
  logger.include(&motor_driver);
  logger.include(&adc);
  logger.include(&ef);
  logger.include(&button_sampler);
  logger.include(&spectral_sensor);
  logger.include(&thermistor);
  logger.init();

  printer.init();
  ef.init();
  button_sampler.init();
  imu.init();
  motor_driver.init();
  spectral_sensor.init();
  thermistor.init(THERMISTOR_PIN);

  // Initialize the LEDs
  status_leds.init(RED_LED_PIN, GREEN_LED_PIN, WHITE_LED_PIN);

  int diveDelay = 6000; // how long robot will stay at depth waypoint before continuing (ms)

   // 15 / 0.25 = 60
   double depth_waypoints[60]; 
   double current_depth = 0.25;

	for (int i = 0; i < 60; i++) {
		depth_waypoints[i] = current_depth;
		current_depth += 0.25;
	}

  depth_control.init(num_depth_waypoints, depth_waypoints, diveDelay);
  
  z_state_estimator.init();

  printer.printMessage("Starting main loop",10);
  loopStartTime = millis();
  printer.lastExecutionTime            = loopStartTime - LOOP_PERIOD + PRINTER_LOOP_OFFSET ;
  imu.lastExecutionTime                = loopStartTime - LOOP_PERIOD + IMU_LOOP_OFFSET;
  adc.lastExecutionTime                = loopStartTime - LOOP_PERIOD + ADC_LOOP_OFFSET;
  ef.lastExecutionTime                 = loopStartTime - LOOP_PERIOD + ERROR_FLAG_LOOP_OFFSET;
  button_sampler.lastExecutionTime     = loopStartTime - LOOP_PERIOD + BUTTON_LOOP_OFFSET;
  z_state_estimator.lastExecutionTime  = loopStartTime - LOOP_PERIOD + Z_STATE_ESTIMATOR_LOOP_OFFSET;
  depth_control.lastExecutionTime      = loopStartTime - LOOP_PERIOD + DEPTH_CONTROL_LOOP_OFFSET;
  logger.lastExecutionTime             = loopStartTime - LOOP_PERIOD + LOGGER_LOOP_OFFSET;
  spectral_sensor.lastExecutionTime    = loopStartTime - LOOP_PERIOD + SPECTRAL_LOOP_OFFSET;
  status_leds.lastExecutionTime 	   = loopStartTime - LOOP_PERIOD + LED_LOOP_OFFSET;
  thermistor.lastExecutionTime  	   = loopStartTime - LOOP_PERIOD + THERMISTOR_LOOP_OFFSET;

  // Set the timer for 2 minutes from when setup finishes
  deploymentStartTime = loopStartTime + DEPLOY_DELAY_MS;
}

//////////////////////////////* Loop */////////////////////////

void loop() {
  currentTime = millis();

  bool isDelayPhase = (currentTime < deploymentStartTime);
  uint32_t timeUntilStart = isDelayPhase ? (deploymentStartTime - currentTime) : 0;
  
  // Check if any error flags are triggered
  bool hasError = (EF_States[0] == 1 || EF_States[1] == 1 || EF_States[2] == 1);
  // -----------------------------------------------

  // Update LEDs
  if ( currentTime - status_leds.lastExecutionTime > LOOP_PERIOD ) {
    status_leds.lastExecutionTime = currentTime;
    status_leds.update(currentTime, hasError, isDelayPhase, timeUntilStart);
  }
    
  if ( currentTime - printer.lastExecutionTime > LOOP_PERIOD ) {
    printer.lastExecutionTime = currentTime;
    printer.printValue(0, adc.printSample());
    // printer.printValue(1, ef.printStates());
    printer.printValue(1, button_sampler.printState());
    printer.printValue(2, logger.printState());
    printer.printValue(3, z_state_estimator.printState());  
    printer.printValue(4, depth_control.printWaypointUpdate());
    printer.printValue(5, depth_control.printString());
    printer.printValue(6, motor_driver.printState());
    printer.printValue(7, imu.printRollPitchHeading());        
    printer.printValue(8, imu.printAccels());
    printer.printValue(9, spectral_sensor.printState());
	printer.printValue(10, thermistor.printState());
    printer.printToSerial();  // To stop printing, just comment this line out
  }

  // only need to run this section after robot is in the water
  if (!isDelayPhase){
	/* ROBOT CONTROL Finite State Machine */
	if ( currentTime - depth_control.lastExecutionTime > LOOP_PERIOD ) {
		depth_control.lastExecutionTime = currentTime;
		if ( depth_control.diveState ) {      // DIVE STATE //
		depth_control.complete = false;
		if ( !depth_control.atDepth ) {
			depth_control.dive(&z_state_estimator.state, currentTime);
		}
		//motor_driver.drive(depth_control.uV,0,0);
		}
		motor_driver.drive(depth_control.uV, depth_control.uV, depth_control.uV);
	}
	
	if ( currentTime - adc.lastExecutionTime > LOOP_PERIOD ) {
		adc.lastExecutionTime = currentTime;
		adc.updateSample(); 
	}

	if ( currentTime - ef.lastExecutionTime > LOOP_PERIOD ) {
		ef.lastExecutionTime = currentTime;

		// Check Pressure Sensor
		int pressureVal = analogRead(PRESSURE_PIN);
		if (pressureVal <= 5 || pressureVal >= 1018) {
		EF_States[0] = 1; // 1 means ERROR
		Serial.println("ERROR: Pressure Sensor voltage railed or disconnected!");
		} else {
		EF_States[0] = 0;
		}

		// Check Thermistor
		if (thermistor.errorStatus == true) {
		EF_States[1] = 1;
		Serial.println("ERROR: Thermistor voltage railed or disconnected!");
		} else {
		EF_States[1] = 0;
		}

		// Check Spectral Sensor
		if (spectral_sensor.errorStatus == true) {
		EF_States[2] = 1;
		Serial.println("ERROR: Spectral Sensor failed to init or read!");
		} else {
		EF_States[2] = 0;
		}

		// Pass the calculated software states to the logger
		ef.updateStates(EF_States[0], EF_States[1], EF_States[2]);
	}

	if ( currentTime - button_sampler.lastExecutionTime > LOOP_PERIOD ) {
		button_sampler.lastExecutionTime = currentTime;
		button_sampler.updateState();
	}

	if ( currentTime - imu.lastExecutionTime > LOOP_PERIOD ) {
		imu.lastExecutionTime = currentTime;
		imu.read();     // blocking I2C calls
	}
	
	if ( currentTime - spectral_sensor.lastExecutionTime > LOOP_PERIOD ) {
		spectral_sensor.lastExecutionTime = currentTime;
		spectral_sensor.read();
	}
	
	if ( currentTime - thermistor.lastExecutionTime > LOOP_PERIOD ) {
	thermistor.lastExecutionTime = currentTime;
	thermistor.read();
	}

	if ( currentTime - z_state_estimator.lastExecutionTime > LOOP_PERIOD ) {
		z_state_estimator.lastExecutionTime = currentTime;
		z_state_estimator.updateState(analogRead(PRESSURE_PIN));
	}
	
	if ( currentTime - logger.lastExecutionTime > LOOP_PERIOD && logger.keepLogging ) {
		logger.lastExecutionTime = currentTime;
		logger.log();
	}
  }
}
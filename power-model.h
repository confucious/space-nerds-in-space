#ifndef POWERMODEL_H__
#define POWERMODEL_H__

/*********************************************************************

  This module defines a crude power model based (loosely) on the behavior
   of an electric circuit.
  
   The circuit looks like this:

             R01        R02        R03
 +---------/\/\/-------/\/\/-------/\/\/--------+ S0
 |                                              |
 |           R11        R12         R13         |
 +---------/\/\/-------/\/\/-------/\/\/--------+ S1
 |                                              |
 |           R21        R22         R23         |
 +---------/\/\/-------/\/\/-------/\/\/--------+ S2
 |                                              |
 |           R31        R32         R33         |
 +---------/\/\/-------/\/\/-------/\/\/--------+ S3
 |                                              |
 |           R41        R42         R43         |
 +---------/\/\/-------/\/\/-------/\/\/--------+ S4
 |                                              |
 |           R51        R52         R53         |
 +---------/\/\/-------/\/\/-------/\/\/--------+ S5
 |                                              |
 |           R61        R62         R63         |
 +---------/\/\/-------/\/\/-------/\/\/--------+ S6
 |                                              |
 |                                              |
 |      RS        | | | |                       |
 +----/\/\/------||||||||-----------------------+
                  | | | |
		    V0, Imax

The power supply is a constant voltage supply with a limited
maximum current.   Each row of three resistors represents a
system.  R*1 is a variable resistor controlled by crewmembers
and specific to a device, e.g. Warp power setting, or phaser
power setting.   R*2 is a variable resistor controlled by engineering
to control power consumption of a system.   R*3 is the innate
resistance of the device.


**************************************************************/

struct power_model;

struct power_device;

typedef float (*resistor_sample_fn)(void);

struct power_device *new_device(resistor_sample_fn r1, resistor_sample_fn r2, float r3);
struct power_model *new_power_model(float max_current, float voltage,
					float internal_resistance);
void power_model_add_device(struct power_model *m, struct power_device *device);
void power_model_compute(struct power_model *m);
float device_current(struct power_device *d);
float power_model_total_current(struct power_model *m);
struct power_device *power_model_get_device(struct power_model *m, int i);
void free_power_model(struct power_model *m);

#endif
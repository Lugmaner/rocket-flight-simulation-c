#ifndef PHYSICS_H
#define PHYSICS_H

#include "types.h"

double calc_drag_coefficient(double velocity);
double calc_gravity(State_t state);
double calc_thrust(Constants_t constants, Stage_t stage);
double calc_density(double height);
double calc_aerodrag(Constants_t constants, State_t state);
double calc_acceleration(Rocket_t rocket);
Derivatives_t calc_derivatives(Rocket_t rocket);

#endif

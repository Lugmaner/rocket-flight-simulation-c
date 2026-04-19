#ifndef SIMULATION_H
#define SIMULATION_H

#include <stdio.h>
#include "types.h"

void update_staging(Rocket_t *rocket);
void rk4_step(Rocket_t *rocket, double dt);
void simulate_flight(double time_limit, FILE *file);

#endif

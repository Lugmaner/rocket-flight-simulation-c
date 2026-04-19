#ifndef INIT_H
#define INIT_H

#include "types.h"

void init_state(State_t *state, double mass);
void init_rocket(Rocket_t *rocket, Stage_t *stageConfigs, unsigned numOfStages);

#endif

#include "init.h"
#include <stdlib.h>
#include <stdio.h>

void init_state(State_t *state, double mass){
    state->vel = 0.0; // m/s
    state->height = 0.0; // m
    state->mass = mass;
    state->numOfRemovedStages = 0;
}

void init_rocket(Rocket_t *rocket, Stage_t *stageConfigs, unsigned numOfStages){
    rocket->InitnumOfStages = numOfStages;
    rocket->stages = malloc(numOfStages * sizeof(*rocket->stages));
    if(!rocket->stages){
        fprintf(stderr,"ERROR: malloc");
        return;
    }
    double mass = 0;
    for(unsigned i = 0; i < numOfStages; i++){
        rocket->stages[i] = stageConfigs[i];
        mass += stageConfigs[i].mass;
    }
    State_t newState;
    init_state(&newState, mass);
    rocket->currentStage = &rocket->stages[0];
    rocket->state = newState;
}

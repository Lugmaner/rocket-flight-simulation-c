#include "simulation.h"
#include "physics.h"
#include "init.h"
#include "output.h"
#include <stdlib.h>

void update_staging(Rocket_t *rocket){
    if(rocket->currentStage->mass - rocket->currentStage->dryMass <= 0){
        if(rocket->currentStage == &rocket->stages[rocket->InitnumOfStages-1]){
            rocket->currentStage->mass = rocket->currentStage->dryMass;
        }
        else{
            rocket->currentStage->mass = 0;
            rocket->currentStage = rocket->currentStage + 1;
            rocket->state.numOfRemovedStages += 1;
        }
        double massSum = 0;
        for(unsigned i = rocket->state.numOfRemovedStages; i < rocket->InitnumOfStages; i++){
            massSum += rocket->stages[i].mass;
        }
        rocket->state.mass = massSum;
    }
}

void rk4_step(Rocket_t *rocket, double dt){
    Derivatives_t k1 = calc_derivatives(*rocket);
    Rocket_t tmp = *rocket;
    Stage_t tmpStage = *rocket->currentStage;
    tmp.currentStage = &tmpStage;

    tmp.state.height = rocket->state.height + k1.dh * dt/2;
    tmp.currentStage->mass = rocket->currentStage->mass + k1.dm * dt/2;
    tmp.state.mass = rocket->state.mass + k1.dm * dt/2;
    tmp.state.vel = rocket->state.vel + k1.dv * dt/2;
    Derivatives_t k2 = calc_derivatives(tmp);
    tmp.state.height = rocket->state.height + k2.dh * dt/2;
    tmp.currentStage->mass = rocket->currentStage->mass + k2.dm * dt/2;
    tmp.state.mass = rocket->state.mass + k2.dm * dt/2;
    tmp.state.vel = rocket->state.vel + k2.dv * dt/2;
    Derivatives_t k3 = calc_derivatives(tmp);
    tmp.state.height = rocket->state.height + k3.dh * dt;
    tmp.currentStage->mass = rocket->currentStage->mass + k3.dm * dt;
    tmp.state.mass = rocket->state.mass + k3.dm * dt;
    tmp.state.vel = rocket->state.vel + k3.dv * dt;
    Derivatives_t k4 = calc_derivatives(tmp);

    double dm = (k1.dm + 2*k2.dm + 2*k3.dm + k4.dm) / 6 * dt;
    rocket->state.height += (k1.dh + 2*k2.dh + 2*k3.dh + k4.dh) / 6 * dt;
    rocket->state.vel += (k1.dv + 2*k2.dv + 2*k3.dv + k4.dv) / 6 * dt;
    rocket->currentStage->mass += dm;
    rocket->state.mass += dm;
    update_staging(rocket);
    if(rocket->state.height < 0.0){
        rocket->state.height = 0.0;
        rocket->state.vel = 0.0;
    }
    if(rocket->currentStage->mass < rocket->currentStage->dryMass){
        rocket->currentStage->mass = rocket->currentStage->dryMass;
    }
}

void simulate_flight(double time_limit, FILE *file){
    Rocket_t rocket;
    Constants_t constants[] = {
        {.massStream = 300.0, .crossSectionArea = 10.0, .thrust0 = 1400000.0},
        {.massStream = 300.0, .crossSectionArea = 10.0, .thrust0 = 1400000.0},
        {.massStream = 300.0, .crossSectionArea = 10.0, .thrust0 = 1400000.0},
    };
    Stage_t stageConfigs[] = {
        {.dryMass = 5000.0, .mass = 35000.0, .constants = constants[0]},
        {.dryMass = 5000.0, .mass = 35000.0, .constants = constants[1]},
        {.dryMass = 5000.0, .mass = 35000.0, .constants = constants[2]},
    };
    unsigned numOfStages = sizeof(stageConfigs) / sizeof(stageConfigs[0]);

    if(file != NULL){
        init_file(file);
    }
    init_rocket(&rocket, stageConfigs, numOfStages);
    double cTime = 0.0; // s
    double dTime = 1.0; // s

    while(cTime < time_limit){
        rk4_step(&rocket, dTime);
        printInfo(rocket, cTime + dTime);
        if(file != NULL){
            update_file(file, rocket, cTime + dTime);
        }
        if(rocket.state.height <= 0.0 && cTime > 0.0){
            printf("Rocket hit the ground!!\n");
            break;
        }
        cTime += dTime;
    }
    printf("\nSimulation finished\n");
    free(rocket.stages);
}

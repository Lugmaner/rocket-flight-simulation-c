#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <errno.h>
#define EARTH_GRAV 9.81

typedef struct
{
    double dryMass;
    double massFlow;
    double crossSectionArea;
    double dragCoefficient;
}Constants_t;

typedef struct
{
    double height;
    double vel;
    double thrust;
    double mass;
}State_t;

double calc_density(double height){ //kg/m^3
    double seaDensity = 1.225;
    double scaleHeight = 8500;
    return seaDensity * exp(-height/scaleHeight);
}

double calc_aerodrag(const Constants_t *constants,const State_t *state){ // newton
    double density = calc_density(state->height);
    double v = state->vel;
    double aeroDrag = 0.5 * density * v * v * constants->dragCoefficient * constants->crossSectionArea;
    return v < 0 ? -aeroDrag : aeroDrag;
}

void update_mass(const Constants_t *constants,State_t *state, double dt){
    if(state->mass <= constants->dryMass){
        state->mass = constants->dryMass;
        state->thrust = 0;
        return;
    }
    state->mass -= constants-> massFlow * dt;
}

double calc_acceleration(const Constants_t *constants,const State_t *state){ // m/s^2
    double aeroDrag = calc_aerodrag(constants, state);
    return (state->thrust / state->mass) - (aeroDrag / state->mass) - EARTH_GRAV;
}

void update_velocity(const Constants_t *constants, State_t *state, double dt){
    double acceleration = calc_acceleration(constants, state);
    state->vel += acceleration * dt;
}

void update_height(State_t *state, double dt){
    state->height += state->vel * dt;
    if(state->height < 0.0){
        state->height = 0.0;    // earthContact approximated
    }
}

void update_physics(const Constants_t *constants, State_t *state, double dt){
    update_mass(constants, state ,dt);
    update_velocity(constants, state,dt);
    update_height(state, dt);;
}

int init_simulation(Constants_t *constants, State_t *state){
    if(!constants || !state){return 1;}
    constants->dryMass = 25000.0; // kg
    constants->massFlow = 12500.0; // kg/s
    constants->crossSectionArea = 10.0; //m^2
    constants->dragCoefficient = 0.5;
    state->thrust = 7607000.0; // newton
    state->vel = 0.0; // m/s
    state->mass = 433000.0; // kg
    state->height = 0.0; // m
    return 0;
}

void print_flightInfo(const State_t *state, double cTime, double a, double remFuel, double aeroDrag, double density){
    printf("Time:%.3fs | acceleration:%.3fm/s^2 | Height:%.3fm | velocity:%.3fm/s | mass:%.3fkg | remaining fuel:%.3fkg | aerodrag:%.3fN | airdensity:%.3fkg/m^3\n",
        cTime,
        a,
        state->height,
        state->vel,
        state->mass,
        remFuel,
        aeroDrag,
        density);
}

int simulate_flight(double time_limit){
    Constants_t constants;
    State_t state;
    if(init_simulation(&constants, &state) == 1){
        return 1;
    }
    double cTime = 0.0; // s
    double dTime = 0.01; // s
    double maxHeight = 0.0;
    double maxVelocity = 0.0;
    double lowestDensityAt = 0.0;
    double lowestDensity = calc_density(state.height);

    while (cTime < time_limit)
    {
        update_physics(&constants, &state, dTime);

        if(state.height > maxHeight){maxHeight = state.height;}
        if(fabs(state.vel) > maxVelocity){maxVelocity = fabs(state.vel);}

        double density = calc_density(state.height);
        double acceleration = calc_acceleration(&constants, &state);
        double aeroDrag = calc_aerodrag(&constants, &state);
        double remainingFuel = state.mass - constants.dryMass;
        if(remainingFuel <= 0){remainingFuel = 0;}
        if(density <= lowestDensity && state.height != 0.0){
            lowestDensity = density;
            lowestDensityAt = state.height;
        }

        print_flightInfo(&state, cTime, acceleration, remainingFuel,aeroDrag, density);

        if(state.height <= 0.0 && cTime > 0.0 && state.vel < 0){
            printf("Rocket hit the ground!!");
            break;
        }
        cTime += dTime;
    }
    printf("\nSimulation finished\n");
    printf("Max velocity: %f | Max height: %f\n",maxVelocity,maxHeight);
    printf("Lowest density (%f) at %fm\n",lowestDensity, lowestDensityAt);
    return 0;
}

int main(int argc, char *argv[]){
    if(argc != 2){
        fprintf(stderr,"Usage: %s <time s>\n",argv[0]);
        return 1;
    }
    char *str = argv[1];
    char *end;
    errno = 0;
    double time = strtof(str, &end);
    if(str == end){
        fprintf(stderr,"ERR: No conversion possible\n");
        return 1;
    }
    else if(errno == ERANGE){
        fprintf(stderr,"ERR: Value out of range\n");
    }
    else if(*end != '\0'){
        fprintf(stderr,"ERR: Partial conversion, unexpected characters: %s\n",end);
    }
    else if(time < 0){
        fprintf(stderr,"ERR: Negative time given\n");
        return 1;
    }
    return simulate_flight(time);
}
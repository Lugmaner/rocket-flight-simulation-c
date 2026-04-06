#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <errno.h>
#define EARTH_GRAV 9.81

typedef struct
{
    double dryMass;
    double massStream;
    double crossSectionArea;
    double dragCoefficient;
    double thrust0;
}Constants_t;

typedef struct
{
    double height;
    double vel;
    double mass;
}State_t;

typedef struct
{
    double dh;
    double dv;
    double dm;
}Derivatives_t;

double calc_thrust(const Constants_t *constants, const State_t *state){
    if(state->mass - constants->dryMass <= 0){
        return 0.0;
    }
    return constants->thrust0;
}

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

double calc_acceleration(const Constants_t *constants,const State_t *state){ // m/s^2
    double aeroDrag = calc_aerodrag(constants, state);
    double thrust = calc_thrust(constants,state);
    return (thrust / state->mass) - (aeroDrag / state->mass) - EARTH_GRAV;
}

Derivatives_t calc_derivatives(const Constants_t *constants, const State_t *state){
    Derivatives_t der;
    der.dh = state->vel;
    der.dv = calc_acceleration(constants,state);
    der.dm = (state->mass - constants->dryMass) <= 0 ? 0 : -constants->massStream;
    return der;
}

void euler_step(const Constants_t *constants, State_t *state, double dt){
   Derivatives_t der = calc_derivatives(constants, state);
   state->height += der.dh * dt;
   state->vel += der.dv * dt;
   state->mass += der.dm * dt;
   if(state->height < 0.0){
    state->height = 0.0;
    state->vel = 0.0;    
}
   if(state->mass < constants->dryMass){state->mass = constants->dryMass;}
}

int init_simulation(Constants_t *constants, State_t *state){
    if(!constants || !state){return 1;}
    constants->dryMass = 25000.0; // kg
    constants->massStream = 12500.0; // kg/s
    constants->crossSectionArea = 10.0; //m^2
    constants->dragCoefficient = 0.5;
    constants->thrust0 = 7607000.0; // newton
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
void update_statistics_printInfo(const Constants_t *constants, const State_t *state, double *maxH, double *maxVel,
                                                double *lowestD, double *lowestDAt, double cTime){
        double density = calc_density(state->height);
        double acceleration = calc_acceleration(constants, state);
        double aeroDrag = calc_aerodrag(constants, state);
        double remainingFuel = state->mass - constants->dryMass;

        if(state->height > *maxH){*maxH = state->height;}
        if(fabs(state->vel) > *maxVel){*maxVel = fabs(state->vel);}
        if(remainingFuel <= 0){remainingFuel = 0;}
        if(density <= *lowestD && state->height != 0.0){
            *lowestD = density;
            *lowestDAt = state->height;
        }
        print_flightInfo(state, cTime, acceleration, remainingFuel, aeroDrag, density);
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
        euler_step(&constants, &state, dTime);
        update_statistics_printInfo(&constants, &state, &maxHeight, &maxVelocity, &lowestDensity, &lowestDensityAt, cTime);
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
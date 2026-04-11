#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <errno.h>
#define EARTH_GRAV 9.81
#define SPEED_OF_SOUND 343

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

double calc_drag_coefficient(double velocity){
    double mach = fabs(velocity) / SPEED_OF_SOUND;
    return 0.3 + 0.5 * exp(-pow(((mach - 1.0) / 0.3),2));
}

double calc_gravity(const State_t *state){
    return EARTH_GRAV * pow(6371000.0 / (6371000.0 + state->height), 2);
}

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
    double dragCoefficient = calc_drag_coefficient(state->vel);
    double v = state->vel;
    double aeroDrag = 0.5 * density * v * v * dragCoefficient * constants->crossSectionArea;
    return v < 0 ? -aeroDrag : aeroDrag;
}

double calc_acceleration(const Constants_t *constants,const State_t *state){ // m/s^2
    double aeroDrag = calc_aerodrag(constants, state);
    double thrust = calc_thrust(constants,state);
    double gravity = calc_gravity(state);
    return (thrust / state->mass) - (aeroDrag / state->mass) - gravity;
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

void rk4_step(const Constants_t *constants, State_t *state, double dt){
    Derivatives_t k1 = calc_derivatives(constants, state);
    State_t tmp;
    tmp.height = state->height + k1.dh * dt/2;
    tmp.mass = state->mass + k1.dm * dt/2;
    tmp.vel = state->vel + k1.dv * dt/2;
    Derivatives_t k2 = calc_derivatives(constants, &tmp);
    tmp.height = state->height + k2.dh * dt/2;
    tmp.mass = state->mass + k2.dm * dt/2;
    tmp.vel = state->vel + k2.dv * dt/2;
    Derivatives_t k3 = calc_derivatives(constants, &tmp);
    tmp.height = state->height + k3.dh * dt;
    tmp.mass = state->mass + k3.dm * dt;
    tmp.vel = state->vel + k3.dv * dt;
    Derivatives_t k4 = calc_derivatives(constants, &tmp);

    state->height += (k1.dh + 2*k2.dh + 2*k3.dh + k4.dh) / 6 * dt;
    state->vel += (k1.dv + 2*k2.dv + 2*k3.dv + k4.dv) / 6 * dt;
    state->mass += (k1.dm + 2*k2.dm + 2*k3.dm + k4.dm) / 6 * dt;

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

void init_file(FILE *file){
    fprintf(file, "time s,height m,velocity m/s,mach,acceleration m/s^2,aerodrag N\n");
}

void update_file(FILE *file, const Constants_t *constants, const State_t *state, double cTime){
    fprintf(file,"%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n",
        cTime,
        state->height,
        state->vel,
        state->vel/SPEED_OF_SOUND,
        calc_acceleration(constants, state),
        calc_aerodrag(constants, state)
    );
}

void printInfo(const Constants_t *constants, const State_t *state, double cTime){
    printf("%.3fs| %.3fm | %.3fm/s | %.3f mach | %.3fm/s^2 | %.3fN\n",
        cTime,
        state->height,
        state->vel,
        state->vel/SPEED_OF_SOUND,
        calc_acceleration(constants, state),
        calc_aerodrag(constants, state)
    );
}

int simulate_flight(double time_limit, FILE *file){
    Constants_t constants;
    State_t state;
    if(file != NULL){
        init_file(file);
    }
    if(init_simulation(&constants, &state) == 1){
        return 1;
    }
    double cTime = 0.0; // s
    double dTime = 0.01; // s

    while (cTime < time_limit)
    {
        rk4_step(&constants, &state, dTime);
        printInfo(&constants, &state, cTime + dTime);
        if(file != NULL){
            update_file(file, &constants, &state, cTime + dTime);
        }
        if(state.height <= 0.0 && cTime > 0.0 && state.vel < 0){
            printf("Rocket hit the ground!!\n");
            break;
        }
        cTime += dTime;
    }
    printf("\nSimulation finished\n");
    return 0;
}

int main(int argc, char *argv[]){
    if(argc < 2){
        fprintf(stderr,"Usage: %s <time s> (*optional)<output.csv>\n",argv[0]);
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
    if(argc == 3){
        FILE *outputFile = fopen(argv[2], "w");
        if(!outputFile){
            fprintf(stderr, "ERR: Could not open file: %s\n", argv[2]);
            return 1;
        }
        int status = simulate_flight(time, outputFile);
        fclose(outputFile);
        return status;
    }
    return simulate_flight(time, NULL);
}
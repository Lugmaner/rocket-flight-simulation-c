#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <errno.h>
#define EARTH_GRAV 9.81

typedef struct
{
    double currentThrust;
    double currentAcceleration;
    double currentVelocity;
    double currentHeight;
    double currentMass;
    double dryMass;
    double massFlow;
    double dragCoefficient;
    double currentAeroDrag;
    double crossSectionArea;
    double remainingFuel;
    int isFuelEmpty;
}Rocket_t;

double calc_density(double height){ //kg/m^3
    double seaDensity = 1.225;
    double scaleHeight = 8500;
    return seaDensity * exp(-height/scaleHeight);
}

int update_aerodrag(Rocket_t *rocket){
    if(!rocket){return 1;}
    double density = calc_density(rocket->currentHeight);
    double v = rocket->currentVelocity;
    double aeroDrag = 0.5 * density * v * v * rocket->dragCoefficient * rocket->crossSectionArea;
    rocket->currentAeroDrag = v < 0 ? -aeroDrag : aeroDrag;
    return 0;
}

int update_mass(Rocket_t *rocket, double dt){
    if(!rocket){return 1;}
    if(!rocket->isFuelEmpty){
        rocket->currentMass -= rocket-> massFlow * dt;
    }
    return 0;
}

int update_acceleration(Rocket_t *rocket){
    if(!rocket){return 1;}
    rocket->currentAcceleration = (rocket->currentThrust / rocket->currentMass) - (rocket->currentAeroDrag / rocket->currentMass) - EARTH_GRAV;
    return 0;
}

int update_velocity(Rocket_t *rocket, double dt){
    if(!rocket){return 1;}
    rocket->currentVelocity += rocket->currentAcceleration * dt;
    return 0;
}

int update_height(Rocket_t *rocket, double dt){
    if(!rocket){return 1;}
    rocket->currentHeight += rocket->currentVelocity * dt;
    if(rocket->currentHeight < 0.0){
        rocket->currentHeight = 0.0;    // earthContact approximated
    }
    return 0;
}

int remaining_fuel(Rocket_t *rocket){
    if(!rocket){return 1;}
    if(rocket->currentMass <= rocket->dryMass){
        if(!rocket->isFuelEmpty){
            rocket->isFuelEmpty = 1;
            rocket->remainingFuel = 0.0;
            rocket->currentThrust = 0.0;
            rocket->currentMass = rocket->dryMass;
            printf("WARNING: Out of fuel!!\n");
        }
        return 0;
    }
    rocket->remainingFuel = rocket->currentMass - rocket->dryMass;
    return 0;
}

int update_physics(Rocket_t *rocket, double dt){
    if(update_mass(rocket,dt) == 1){return 1;}
    if(remaining_fuel(rocket) == 1){return 1;}
    if(update_aerodrag(rocket)== 1){return 1;}
    if(update_acceleration(rocket) == 1){return 1;}
    if(update_velocity(rocket,dt) == 1){return 1;}
    if(update_height(rocket,dt) == 1){return 1;}
    return 0;
}

int init_rocket(Rocket_t *rocket){
    if(!rocket){return 1;}
    rocket->currentThrust = 7607000.0; // newton
    rocket->currentAcceleration = 0.0; // m/s^2
    rocket->currentVelocity = 0.0; // m/s
    rocket->currentMass = 433000.0; // kg
    rocket->dryMass = 25000.0; // kg
    rocket->massFlow = 12500.0; // kg/s
    rocket->remainingFuel = rocket->currentMass - rocket->dryMass; // kg
    rocket->currentHeight = 0.0; // m
    rocket->crossSectionArea = 10.0; //m^2
    rocket->dragCoefficient = 0.5;
    rocket->currentAeroDrag = 0.0; // newton
    rocket->isFuelEmpty = 0;
    return 0;
}

int simulate_flight(double time_limit){
    Rocket_t newRocket;
    if(init_rocket(&newRocket) == 1){
        return 1;
    }
    double cTime = 0.0; // s
    double dTime = 0.01; // s
    double maxHeight = 0.0;
    double maxVelocity = 0.0;
    double lowestDensityAt = 0.0;
    double lowestDensity = calc_density(newRocket.currentHeight);

    while (cTime < time_limit)
    {
        if(update_physics(&newRocket, dTime) == 1){return 1;}
        if(newRocket.currentHeight > maxHeight){
            maxHeight = newRocket.currentHeight;
        }
        if(fabs(newRocket.currentVelocity) > maxVelocity){
            maxVelocity = fabs(newRocket.currentVelocity);
        }
        double density = calc_density(newRocket.currentHeight);
        if(density <= lowestDensity && newRocket.currentHeight != 0.0){
            lowestDensity = density;
            lowestDensityAt = newRocket.currentHeight;
        }
        printf("Time:%.3fs | acceleration:%.3fm/s^2 | Height:%.3fm | velocity:%.3fm/s | mass:%.3fkg | remaining fuel:%.3fkg | aerodrag:%.3fN | airdensity:%.3fkg/m^3\n",
        cTime,
        newRocket.currentAcceleration,
        newRocket.currentHeight,
        newRocket.currentVelocity,
        newRocket.currentMass,
        newRocket.remainingFuel,
        newRocket.currentAeroDrag,
        density);

        if(newRocket.currentHeight <= 0.0 && cTime > 0.0 && newRocket.currentVelocity < 0){
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
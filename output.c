#include "output.h"
#include "physics.h"

void init_file(FILE *file){
    fprintf(file, "time s,mass kg,height m,velocity m/s,mach,acceleration m/s^2,aerodrag N,numOfStages\n");
}

void update_file(FILE *file, Rocket_t rocket, double cTime){
    fprintf(file,"%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%u\n",
        cTime,
        rocket.state.mass,
        rocket.state.height,
        rocket.state.vel,
        rocket.state.vel/SPEED_OF_SOUND,
        calc_acceleration(rocket),
        calc_aerodrag(rocket.currentStage->constants, rocket.state),
        (rocket.InitnumOfStages-rocket.state.numOfRemovedStages)
    );
}

void printInfo(Rocket_t rocket, double cTime){
    printf("%.3fs| %.3fkg | %.3fm | %.3fm/s | %.3f mach | %.3fm/s^2 | %.3fN | %u stages\n",
        cTime,
        rocket.state.mass,
        rocket.state.height,
        rocket.state.vel,
        rocket.state.vel/SPEED_OF_SOUND,
        calc_acceleration(rocket),
        calc_aerodrag(rocket.currentStage->constants, rocket.state),
        (rocket.InitnumOfStages-rocket.state.numOfRemovedStages)
    );
}

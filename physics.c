#include "physics.h"
#include <math.h>

double calc_drag_coefficient(double velocity){
    double mach = fabs(velocity) / SPEED_OF_SOUND;
    return 0.3 + 0.5 * exp(-pow(((mach - 1.0) / 0.3),2));
}

double calc_gravity(State_t state){
    return EARTH_GRAV * pow(6371000.0 / (6371000.0 + state.height), 2);
}

double calc_thrust(Constants_t constants, Stage_t stage){
    if(stage.mass - stage.dryMass <= 0){
        return 0.0;
    }
    return constants.thrust0;
}

double calc_density(double height){ //kg/m^3
    double seaDensity = 1.225;
    double scaleHeight = 8500;
    return seaDensity * exp(-height/scaleHeight);
}

double calc_aerodrag(Constants_t constants, State_t state){ // newton
    double density = calc_density(state.height);
    double dragCoefficient = calc_drag_coefficient(state.vel);
    double v = state.vel;
    double aeroDrag = 0.5 * density * v * v * dragCoefficient * constants.crossSectionArea;
    return v < 0 ? -aeroDrag : aeroDrag;
}

double calc_acceleration(Rocket_t rocket){ // m/s^2
    double aeroDrag = calc_aerodrag(rocket.currentStage->constants, rocket.state);
    double thrust = calc_thrust(rocket.currentStage->constants,*rocket.currentStage);
    double gravity = calc_gravity(rocket.state);
    return (thrust / rocket.state.mass) - (aeroDrag / rocket.state.mass) - gravity;
}

Derivatives_t calc_derivatives(Rocket_t rocket){
    Derivatives_t der;
    der.dh = rocket.state.vel;
    der.dv = calc_acceleration(rocket);
    der.dm = (rocket.currentStage->mass - rocket.currentStage->dryMass) <= 0 ? 0 : -rocket.currentStage->constants.massStream;
    return der;
}

#ifndef TYPES_H
#define TYPES_H

#define EARTH_GRAV 9.81
#define SPEED_OF_SOUND 343

typedef struct
{
    double massStream;
    double crossSectionArea;
    double thrust0;
}Constants_t;

typedef struct
{
    double height;
    double vel;
    double mass;
    unsigned numOfRemovedStages;
}State_t;

typedef struct
{
    double dh;
    double dv;
    double dm;
}Derivatives_t;

typedef struct
{
    double dryMass;
    double mass;
    Constants_t constants;
}Stage_t;

typedef struct
{
    State_t state;
    Stage_t *currentStage;
    unsigned InitnumOfStages;
    Stage_t *stages;
}Rocket_t;

#endif

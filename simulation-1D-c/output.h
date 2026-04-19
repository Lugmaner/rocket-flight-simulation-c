#ifndef OUTPUT_H
#define OUTPUT_H

#include <stdio.h>
#include "types.h"

void init_file(FILE *file);
void update_file(FILE *file, Rocket_t rocket, double cTime);
void printInfo(Rocket_t rocket, double cTime);

#endif

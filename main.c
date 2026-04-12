#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "simulation.h"

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
        simulate_flight(time, outputFile);
        fclose(outputFile);
        return 0;
    }
    simulate_flight(time, NULL);
    return 0;
}

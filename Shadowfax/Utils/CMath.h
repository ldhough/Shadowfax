//
//  CMath.h
//  Shadowfax
//
//  Created by Lannie Hough on 11/23/20.
//

#ifndef CMath_h
#define CMath_h

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

float randomNum(int maxRand, int timesMaxR);
void diamondStep(void *array, int step, int size, float magnitude, int maxR, int timesMaxR);
void squareStep(void *array, int step, int size, int *prevRows, int *prevDist, float magnitude, int maxR, int timesMaxR);
void* diamondSquareGenHeightmap(/*void *arr,*/ int size, int maxRand, int timesMaxR, float c1, float c2, float c3, float c4);

#endif /* CMath_h */

#include "stdio.h"
#define ARRAY_SIZE 64

int main() {
    int* a = (int*)malloc(sizeof(int) * ARRAY_SIZE);
    // fill the 3 ways of the particular set (fixed them at LRU position for LRU-LIP policy)
    a[0] = 0;
    a[0] = 0;
    a[8] = 0;
    a[8] = 0;
    a[16] = 0;
    a[16] = 0;
    // hits for LRU-LIP, misses for LRU
    for(int j=0; j<10000; j++) {
        a[0] = 0;
        a[8] = 0;
        a[16] = 0;
        a[24] = 0;
        a[32] = 0; 
    }
    return 0;
}
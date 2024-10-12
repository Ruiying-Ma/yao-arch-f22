#include "stdio.h"
#define ARRAY_SIZE 64

int main() {
    int* a = (int*)malloc(sizeof(int) * ARRAY_SIZE);
    // fill the 4 ways of the particular set
    a[0] = 0;
    a[8] = 0;
    a[16] = 0;
    a[24] = 0;
    // hits for LRU (except the cold misses), misses for LRU-LIP
    for(int j=0; j<10000; j++) {
        a[32] = 0;
        a[40] = 0;
        a[48] = 0;
        a[56] = 0;
    }
        return 0;
}

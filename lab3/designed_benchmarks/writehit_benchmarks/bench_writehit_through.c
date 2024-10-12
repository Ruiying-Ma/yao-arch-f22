#include "stdio.h"
#define ARRAY_SIZE 16

int main () {
    int* a = (int*)malloc(sizeof(int) * ARRAY_SIZE * 1000);
    for(int j=0; j<ARRAY_SIZE * 1000; j++) {
        a[j] = 0;
    }
    return 0;
}
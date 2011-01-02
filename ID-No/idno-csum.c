#include <stdio.h>
#include <math.h>
#include <string.h>

void usage(int argc, const char *argv[]);

int main(int argc, const char *argv[])
{

    if (argc != 2) {
        usage(argc, argv);
        return 0;
    }
    if (strlen(argv[1]) != 17) {
        printf("please input the first 17 digit of ID number\n");
        return 0;
    }

    int i = 2;
    int S = 0;
    int csum = 0;
    for(i = 2; i <= 18; ++i) {
        S += ((int)(argv[1][18-i]-48)) * ((int)pow(2, i-1));
    }
    csum = (12 - (S%11))%11;
    printf("csum = %d\n", csum);
    return 0;
}

void usage(int argc, const char *argv[])
{
    printf("Usage: %s <id num>\n", argv[0]);
}

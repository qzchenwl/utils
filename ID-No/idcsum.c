#include <stdio.h>
#include <string.h>

/**
 * Print usage for the program
 */
void usage(int argc, const char *argv[]);

/**
 * return checksum of ID number
 * return -1 for error
 */
int id_csum(const char idnum[]);

int main(int argc, const char *argv[])
{

    if (argc != 2) {
        usage(argc, argv);
        return 0;
    }
    int csum = id_csum(argv[1]);
    if(csum == -1) {
        return -1;
    }
    printf("csum = %d\n", csum);
    return 0;
}

int id_csum(const char idnum[])
{

    int i,S,csum,len;
    int W[] = {7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2,1};
    len = strlen(idnum);
    if (len < 17) {
        fprintf(stderr, "ERROR: Need first 17 digit of ID, got %d\n", len);
        return -1;
    }
    if (len > 17) {
        fprintf(stderr, "WARNING: Need first 17 digit of ID, got %d\n", len);
    }
    for(i=0,S=0,csum=0; i<17; ++i) {
        S += (idnum[i]-48) * W[i]; // char-48, ascii2int
    }
    csum = (12 - (S % 11)) % 11;
    return csum;
}

void usage(int argc, const char *argv[])
{
    printf("Usage: %s <id num>\n", argv[0]);
}

#include <stdio.h>
#include <unistd.h>

#define MAXGEN 100
#define SPEED_FILE "speed.txt"

int main() {
    int generation;
    generation = 0;

    while (1) {
        printf("PID = %i, generation = %i\n", getpid(), generation);

        FILE* cf = fopen(SPEED_FILE, "r");
        int delay;
        fscanf(cf, "%i", &delay);
        fclose(cf);

        if (delay == 0)
        {
            puts("forker ended work.");
            return;
        }

        usleep(1000000 * delay);

        if (fork() != 0) {
            return 0;
        }

        generation++;

        if (generation > MAXGEN)
            return 0;
    }

    return 0;
}

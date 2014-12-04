#include <stdio.h>
#include <signal.h>
#include <unistd.h>

#define SPEED_FILE "speed.txt"
#define START_DELAY 5

int delay = START_DELAY;

void set(int d) {
    printf("Setting delay: %i\n", d);
    FILE* cf = fopen(SPEED_FILE, "w");
    fprintf(cf, "%i", d);
    delay = d;
    fclose(cf);
}

void on_up() {
    set(delay + 1);
}

void on_down() {
    if (delay > 0)
        set(delay - 1);
}


int main() {
    signal(SIGUSR1, on_up);
    signal(SIGUSR2, on_down);

    if (fork() != 0) {
        return 0;
    } else {
       printf("Signal controller PID = %i\n", getpid());
    }

    while (1) {
        usleep(1000000);
        if (delay == 0) {
            return 0;
        }
    }

    return 0;
}

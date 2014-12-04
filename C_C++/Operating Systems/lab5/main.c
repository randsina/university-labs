#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <time.h>

#define CHILD_COUNT 3

time_t start_time;

//FD = file descriptor
void child(fd, id) {
    printf("[child %i] started, pid = %i, pipe FD (out) = %i\n", id, getpid(), fd);

    while (1) {
        char buffer[1024];
        time_t current_time = time(0) - start_time;
        switch (id) {
			case 0:
				sprintf(buffer,  "[child %i], time = %i <-\n", id, (int)current_time);
				break;
			case 1:
				sprintf(buffer,  "[child %i], time = %i\n", id, (int)current_time);
				break;
			default:
				sprintf(buffer,  "[child %i], time = %i\n", id, (int)current_time);
		}

        write(fd, buffer, strlen(buffer) + 1);
        if (id == CHILD_COUNT-1)
			write(fd, buffer, strlen(buffer) + 1);

        sleep((id+1)*1);
    }
}


int main() {
	start_time = time(0);
    int i;
    int fds[CHILD_COUNT];

    for (i = 0; i < CHILD_COUNT; i++) {
        int fd[2];
        pipe(fd);

		int pid = fork();
        if (pid == 0) {
            child(fd[1], i); // fd[1] = output for child process
            return 0;
        } else {
            printf("[parent] created child %i, pid = %i, pipe FD (in) = %i\n", i, pid, fd[0]);
            fds[i] = fd[0]; // fd[0] = input for parent process
        }
    }

    while (1) {
        for (i = 0; i < CHILD_COUNT; i++) {
            char buffer[1024];
            int count = read(fds[i], buffer, 1024);
            if (count > 0) {
                printf("%s", buffer);
            }
        }
    }

    return 0;
}

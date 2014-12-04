#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <time.h>

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_WHITE   "\x1b[37;1m"
#define ANSI_COLOR_RESET   "\x1b[0m"

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
				sprintf(buffer, ANSI_COLOR_GREEN "[child %i], time = %i <-" ANSI_COLOR_RESET "\n", id, (int)current_time);
				break;
			case 1:
				sprintf(buffer, ANSI_COLOR_YELLOW "[child %i], time = %i" ANSI_COLOR_RESET "\n", id, (int)current_time);
				break;
			default:
				sprintf(buffer, ANSI_COLOR_RED "[child %i], time = %i" ANSI_COLOR_RESET "\n", id, (int)current_time);
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
        //pipe2(fd, O_NONBLOCK);
		/* The pipe() function creates a pipe, which is an object allowing unidirec-
		tional data flow, and allocates a pair of file descriptors.  The first
		descriptor connects to the read end of the pipe, and the second connects
		to the write end, so that data written to fildes[1] appears on (i.e., can
		be read from) fildes[0].  This allows the output of one program to be
		sent to another program: the source's standard output is set up to be the
		write end of the pipe, and the sink's standard input is set up to be the
		read end of the pipe.  The pipe itself persists until all its associated
		descriptors are closed. */

		int pid = fork();
        if (pid == 0) {
            child(fd[1], i); // fd[1] = output for child process
            return 0;
        } else {
            printf("[parent] created child %i, pid = %i, pipe FD (in) = %i\n", i, pid, fd[0]);
            fds[i] = fd[0]; // fd[0] = input for parent process
        }
        //usleep(1000000);
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

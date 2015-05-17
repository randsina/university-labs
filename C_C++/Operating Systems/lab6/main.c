// file arguments is input and output files

#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <pthread.h>
#include <sys/stat.h>
#include <semaphore.h>

#define BUFSIZE 1000
#define SEM_SIZE (sizeof(sem_t))
#define SHM_SIZE (SEM_SIZE * 2 + sizeof(int) + BUFSIZE)
#define SHM_KEY 22222

int main(int argc, char** argv) {
    char* file_in = argv[1];
    char* file_out = argv[2];

    FILE* fin = fopen(file_in, "r");
    FILE* fout = fopen(file_out, "w");

    // allocates a shared memory segment, shm = id of shared memory segment
    int shm = shmget(SHM_KEY, SHM_SIZE, 0666 | IPC_CREAT);

    void* shma = shmat(shm, NULL, 0);

    sem_t* sem_write = shma;
    sem_t* sem_read = shma + SEM_SIZE;
    int*   size = shma + SEM_SIZE * 2;
    void*  buffer = size + sizeof(int);

    sem_init(sem_write, 1, 0); // initialise the semaphore
    sem_init(sem_read, 1, 0);

    if (fork() == 0) {
        int len;
        while ((len = fread(buffer, 1, BUFSIZE, fin))) {
            printf("[pid = %i] read %i bytes\n", getpid(), len);
            *size = len;
            sem_post(sem_read);
            sem_wait(sem_write);
        }
        *size = 0;
        printf("[pid = %i] done reading, exiting\n", getpid());
        fclose(fin);
        sem_post(sem_read);
        return 0;
    } else {
        while (1) {
            sem_wait(sem_read);
            if (*size == 0)
                break;
            fwrite(buffer, 1, *size, fout);
            printf("[pid = %i] wrote %i bytes\n", getpid(), *size);
            sem_post(sem_write);
        }
        fclose(fout);
        printf("[pid = %i] done writing, exiting\n", getpid());
    }

    return 0;
}

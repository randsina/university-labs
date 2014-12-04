#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <pthread.h>

#define ANSI_COLOR_RED    "\x1b[31m"
#define ANSI_COLOR_YELLOW "\x1b[33m"
#define ANSI_COLOR_GREEN  "\x1b[32m"
#define ANSI_COLOR_WHITE  "\x1b[37;1m"
#define ANSI_COLOR_RESET  "\x1b[0m"
#define PORT 9000
#define MAX_SIZE 1024

void worker(client) {
    #ifdef THREADS
    printf(ANSI_COLOR_GREEN"* thread %i started, client FD %i"ANSI_COLOR_RESET"\n", (int)pthread_self(), client);
    #else
    printf(ANSI_COLOR_GREEN"* child process %i started, client FD %i"ANSI_COLOR_RESET"\n", getpid(), client);
    #endif

    char input_message[MAX_SIZE];
    recv(client, input_message, MAX_SIZE, 0);
    //printf(ANSI_COLOR_YELLOW"%s"ANSI_COLOR_RESET, input_message); // browser request full
    
    strtok(input_message, " "); // split string into tokens
    char* url = strtok(NULL, " "); // getting next (second) token value

    printf(ANSI_COLOR_YELLOW"Request: GET %s HTTP/1.1"ANSI_COLOR_RESET"\n", url, client);

    char header[MAX_SIZE];
    char content[MAX_SIZE];
    sprintf(content, "<html><body>Requested url: %s</body></html>", url);
    sprintf(header, "HTTP/1.1 200 OK\r\nConnection: close\r\nContent-Length: %i\r\n\r\n", strlen(content));
    send(client, header, strlen(header), 0);
    send(client, content, strlen(content), 0);
    
    puts(ANSI_COLOR_RED"Response sended."ANSI_COLOR_RESET);
    
    close(client);
    
    #ifdef THREADS
    pthread_exit(0);
    #endif
}

int main() {
    puts("* parent process started.");
    
    #ifdef THREADS
    puts("* working with threads");
    pthread_t threads[MAX_SIZE];
    #else
    puts("* working with child processes");
    pid_t pids[MAX_SIZE];
    #endif

    time_t ticks[MAX_SIZE]; // save running time for each child
    int child_index = 0;
    
    puts("#1. socket");
    int listener = socket(AF_INET, SOCK_STREAM, 0);

    struct sockaddr_in server_address;
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);
    
    puts("#2. bind");
    bind(listener, (struct sockaddr *)&server_address, sizeof(server_address));
    
    puts("#3. listen");
    listen(listener, 10);

    while (1) {
        puts("#4. accept");
        int client = accept(listener, 0, 0);

        #ifdef THREADS
        pthread_create(&threads[child_index], 0, (void*(*)(void*)) &worker, (void*)client);
        #else
        int pid = fork();
        #endif

        int i;
        for (i = 0; i < child_index; i++)
            #ifdef THREADS
            if (threads[i].thread_id != 0 && time(0) - ticks[i] > 3) {
                pthread_kill(threads[i], SIGTERM);
                threads[i].thread_id = 0;
            }
            #else
            if (pids[i] != 0 && time(0) - ticks[i] > 3) {
                kill(pids[i], SIGTERM);
                pids[i] = 0;
            }
            #endif

        ticks[child_index] = time(0);

        #ifndef THREADS
        if (pid != 0) {
            pids[child_index++] = pid;
            close(client);
        } else {
            worker(client);
            return 0;
        }
        #endif
        
        sleep(1);
    }

    #ifdef THREADS
    pthread_exit(0);
    #endif

    return 0;
}

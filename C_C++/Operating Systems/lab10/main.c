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
#define PORT 8000
#define MAX_MESSAGE_LENGTH 1024

void server(listener)
{
    puts("echo daemon started.");
    puts("'bye' - for closing connection, 'terminate' - for terminating daemon.");

    char input_message[MAX_MESSAGE_LENGTH];

    while (1) {
        puts("#4. accept");
        int client = accept(listener, 0, 0);

        while (1) {
            puts("#5. recv - receiving a message from a socket");
            ssize_t message_length = recv(client, input_message, MAX_MESSAGE_LENGTH, 0);
            input_message[message_length-2] = 0;

            printf("client request: %s\n", input_message);

            if (strcmp(input_message, "bye") == 0) {
                close(client);
                puts("connection closed.");
                break;
            } else if (strcmp(input_message, "terminate") == 0) {
                close(client);
                puts("daemon terminated.");
                return;
            }

            puts("#8. send - sending echo to a socket");
            send(client, input_message, message_length, 0);

        }
        sleep(1);
    }
}

int main() {
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

    if (fork() != 0) {
        return 0;
    } else {
        server(listener);
    }

    return 0;
}

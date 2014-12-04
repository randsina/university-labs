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

#define ANSI_COLOR_RED   "\x1b[31m"
#define ANSI_COLOR_GREEN "\x1b[32m"
#define ANSI_COLOR_WHITE "\x1b[37;1m"
#define ANSI_COLOR_RESET "\x1b[0m"
#define PORT 8000
#define MAX_MESSAGE_LENGTH 1024

void server(listener)
{
    puts(ANSI_COLOR_GREEN"echo daemon started."ANSI_COLOR_RESET);
    puts(ANSI_COLOR_GREEN"'bye' - for closing connection, 'terminate' - for terminating daemon."ANSI_COLOR_RESET);
    
    char input_message[MAX_MESSAGE_LENGTH];
    
    while (1) {
        puts("#4. accept");
        int client = accept(listener, 0, 0);
        //In the call to accept(), the server is put to sleep and when
        //for an incoming client request, the three way TCP handshake* is complete,
        //the function accept () wakes up and returns the socket descriptor
        //representing the client socket.
        //The call to accept() is run in an infinite loop so that the server
        //is always running and the delay or sleep of 1 sec ensures
        //that this server does not eat up all of your CPU processing.
        //As soon as server gets a request from client, it prepares the output data
        //and writes on the client socket through the descriptor returned by accept().
        
        while (1) {
            puts("#5. recv - receiving a message from a socket");
            ssize_t message_length = recv(client, input_message, MAX_MESSAGE_LENGTH, 0);
            input_message[message_length-2] = 0;
            
            printf(ANSI_COLOR_GREEN"client request: "ANSI_COLOR_WHITE"%s\n"ANSI_COLOR_RESET, input_message);
            
            if (strcmp(input_message, "bye") == 0) {
                close(client);
                puts(ANSI_COLOR_RED"connection closed."ANSI_COLOR_RESET);
                break;
            } else if (strcmp(input_message, "terminate") == 0) {
                close(client);
                puts(ANSI_COLOR_RED"daemon terminated."ANSI_COLOR_RESET);
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
    //The call to the function ‘socket()’ creates an UN-named socket
    //inside the kernel and returns an integer known as socket descriptor.
    //This function takes domain/family as its first argument.
    //For Internet family of IPv4 addresses we use AF_INET.
    //The second argument ‘SOCK_STREAM’ specifies that the transport layer protocol
    //that we want should be reliable ie it should have acknowledgement techniques. 

    struct sockaddr_in server_address;
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);
    
    puts("#2. bind");
    bind(listener, (struct sockaddr *)&server_address, sizeof(server_address));
    //The call to the function ‘bind()’ assigns the details specified
    //in the structure ‘serv_addr’ to the socket created in the step above.
    //The details include, the family/domain, the interface to listen on
    //(in case the system has multiple interfaces to network)
    //and the port on which the server will wait for the client requests to come.
    
    puts("#3. listen");
    listen(listener, 10);
    //The call to the function ‘listen()’ with second argument as ’10′ specifies
    //maximum number of client connections that server will queue for this listening socket.
    //After the call to listen(), this socket becomes a fully functional listening socket.

    if (fork() != 0) {
        return 0;
    } else {
        server(listener);
    }

    return 0;
}

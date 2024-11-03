#include <stdio.h>
#include <unistd.h>

int main() {
    const char *text = "Hello, World!";
    
    for (int color = 30; color <= 37; color++) {
        printf("\033[%dm%s\033[0m\n", color, text);
        usleep(200000);
    }
    for (int color = 90; color <= 97; color++) {
        printf("\033[%dm%s\033[0m\n", color, text);
        usleep(200000);
    }
    
    return 0;
}

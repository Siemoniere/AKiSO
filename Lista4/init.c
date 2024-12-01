#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <string.h>

int main() {
    if (kill(1, SIGKILL) == 0) {
        printf("Sygnał SIGKILL został wysłany do procesu init.\n");
    } else {
        printf("Nie można wysłać SIGKILL do procesu init: %s\n", strerror(errno));
    }
    return 0;
}

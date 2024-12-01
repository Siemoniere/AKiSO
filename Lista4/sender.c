#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Użycie: %s <PID> <Liczba sygnałów>\n", argv[0]);
        return 1;
    }

    pid_t pid = atoi(argv[1]);
    int count = atoi(argv[2]);

    for (int i = 0; i < count; i++) {
        if (kill(pid, SIGUSR1) == -1) {
            perror("Nie udało się wysłać sygnału");
            return 1;
        }
    }

    printf("Wysłano %d sygnałów SIGUSR1 do procesu %d.\n", count, pid);
    return 0;
}

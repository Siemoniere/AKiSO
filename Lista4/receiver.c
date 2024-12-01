#include <stdio.h>
#include <signal.h>
#include <unistd.h>

volatile sig_atomic_t signal_count = 0;

void signal_handler(int signum) {
    signal_count++;
}

int main() {
    struct sigaction sa;
    sa.sa_handler = signal_handler;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);

    if (sigaction(SIGUSR1, &sa, NULL) == -1) {
        perror("Nie udało się ustawić obsługi SIGUSR1");
        return 1;
    }

    printf("Proces gotowy, PID: %d\n", getpid());
    while (1) {
        printf("Odebrane sygnały SIGUSR1: %d\n", signal_count);
        sleep(1);
    }

    return 0;
}

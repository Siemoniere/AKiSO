#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>

void signal_handler(int sig) {
    printf("Odebrano sygnał: %d (%s)\n", sig, strsignal(sig));
}

int main() {
    struct sigaction sa;
    sa.sa_handler = signal_handler;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    for (int i = 1; i < NSIG; i++) {
        if (sigaction(i, &sa, NULL) == -1) {
            fprintf(stderr, "Nie można przechwycić sygnału %d (%s)\n", i, strsignal(i));
        }
    }
    printf("Program czeka na sygnały...\n");
    while (1) {
        pause();
    }
    return 0;
}

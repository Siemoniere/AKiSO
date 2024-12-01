#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <stdbool.h>

// Funkcja obsługująca komendę cd
void lsh_cd(char **args) {
    if (args[1] == NULL) {
        fprintf(stderr, "lsh: expected argument to \"cd\"\n");
    } else {
        if (chdir(args[1]) != 0) {
            perror("lsh");
        }
    }
}

// Funkcja obsługująca komendę exit
void lsh_exit() {
    printf("Exiting lsh...\n");
    exit(0);
}

// Funkcja do rozdzielania linii na argumenty
int lsh_parse_line(char *line, char **args) {
    int argc = 0;
    char *token = strtok(line, " \t\n");
    while (token != NULL && argc < MAX_ARGS - 1) {
        args[argc++] = token;
        token = strtok(NULL, " \t\n");
    }
    args[argc] = NULL;
    return argc;
}

// Funkcja do obsługi procesów zombie
void reap_zombies() {
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

// Funkcja do uruchamiania komend zewnętrznych
void lsh_execute(char **args, bool background) {
    pid_t pid = fork();
    if (pid == 0) {
        // Proces potomny
        if (execvp(args[0], args) == -1) {
            perror("lsh");
        }
        exit(EXIT_FAILURE);
    } else if (pid < 0) {
        // Błąd w fork()
        perror("lsh");
    } else {
        // Proces nadrzędny
        if (!background) {
            waitpid(pid, NULL, 0);
        }
    }
}

int main() {
    char line[1024];
    char *args[100];

    while (true) {
        printf("lsh> ");
        fflush(stdout);

        // Odczyt linii komend
        if (fgets(line, sizeof(line), stdin) == NULL) {
            printf("\n"); // Ctrl+D
            break;
        }

        // Usuwanie zakończonych procesów w tle
        reap_zombies();

        // Parsowanie linii
        int argc = lsh_parse_line(line, args);
        if (argc == 0) {
            continue; // Pusta linia
        }

        // Obsługa komend wbudowanych
        if (strcmp(args[0], "cd") == 0) {
            lsh_cd(args);
        } else if (strcmp(args[0], "exit") == 0) {
            lsh_exit();
        } else {
            // Sprawdzenie, czy komenda ma być uruchomiona w tle
            bool background = false;
            if (argc > 0 && strcmp(args[argc - 1], "&") == 0) {
                background = true;
                args[argc - 1] = NULL; // Usuń '&' z argumentów
            }
            lsh_execute(args, background);
        }
    }

    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <fcntl.h>
#include <stdbool.h>

#define MAX_LINE 1024
#define MAX_ARGS 100

// Globalna zmienna do obsługi sygnałów
volatile sig_atomic_t child_pid = -1;

// Funkcja obsługująca sygnał Ctrl-C
void sigint_handler(int sig) {
    if (child_pid > 0) {
        kill(child_pid, SIGINT);
    }
}

// Funkcja do rozdzielania linii na argumenty
int parse_line(char *line, char **args) {
    int argc = 0;
    char *token = strtok(line, " \t\n");
    while (token != NULL && argc < MAX_ARGS - 1) {
        args[argc++] = token;
        token = strtok(NULL, " \t\n");
    }
    args[argc] = NULL;
    return argc;
}

// Funkcja do obsługi przekierowań
void handle_redirection(char **args) {
    for (int i = 0; args[i] != NULL; i++) {
        if (strcmp(args[i], ">") == 0) {
            int fd = open(args[i + 1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (fd < 0) {
                perror("lsh");
                exit(EXIT_FAILURE);
            }
            dup2(fd, STDOUT_FILENO);
            close(fd);
            args[i] = NULL;
        } else if (strcmp(args[i], "2>") == 0) {
            int fd = open(args[i + 1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (fd < 0) {
                perror("lsh");
                exit(EXIT_FAILURE);
            }
            dup2(fd, STDERR_FILENO);
            close(fd);
            args[i] = NULL;
        } else if (strcmp(args[i], "<") == 0) {
            int fd = open(args[i + 1], O_RDONLY);
            if (fd < 0) {
                perror("lsh");
                exit(EXIT_FAILURE);
            }
            dup2(fd, STDIN_FILENO);
            close(fd);
            args[i] = NULL;
        }
    }
}

// Funkcja do obsługi potoków
void execute_pipe(char **cmd1, char **cmd2) {
    int pipefd[2];
    if (pipe(pipefd) < 0) {
        perror("lsh");
        exit(EXIT_FAILURE);
    }

    pid_t pid1 = fork();
    if (pid1 == 0) {
        dup2(pipefd[1], STDOUT_FILENO);
        close(pipefd[0]);
        close(pipefd[1]);
        execvp(cmd1[0], cmd1);
        perror("lsh");
        exit(EXIT_FAILURE);
    } else if (pid1 < 0) {
        perror("lsh");
    }

    pid_t pid2 = fork();
    if (pid2 == 0) {
        dup2(pipefd[0], STDIN_FILENO);
        close(pipefd[1]);
        close(pipefd[0]);
        execvp(cmd2[0], cmd2);
        perror("lsh");
        exit(EXIT_FAILURE);
    } else if (pid2 < 0) {
        perror("lsh");
    }

    close(pipefd[0]);
    close(pipefd[1]);
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);
}

// Funkcja do uruchamiania poleceń
void execute_command(char **args, bool background) {
    child_pid = fork();
    if (child_pid == 0) {
        handle_redirection(args);
        execvp(args[0], args);
        perror("lsh");
        exit(EXIT_FAILURE);
    } else if (child_pid < 0) {
        perror("lsh");
    } else {
        if (!background) {
            waitpid(child_pid, NULL, 0);
        }
        child_pid = -1;
    }
}

// Funkcja główna
int main() {
    char line[MAX_LINE];
    char *args[MAX_ARGS];
    char *cmd1[MAX_ARGS], *cmd2[MAX_ARGS];

    signal(SIGINT, sigint_handler);

    printf("Welcome to lsh (with pipes and redirection). Type 'exit' to quit.\n");

    while (1) {
        printf("lsh> ");
        fflush(stdout);

        if (fgets(line, sizeof(line), stdin) == NULL) {
            printf("\n");
            break;
        }

        int argc = parse_line(line, args);
        if (argc == 0) {
            continue; // Pusta linia
        }

        // Wbudowane komendy
        if (strcmp(args[0], "cd") == 0) {
            if (args[1] == NULL) {
                fprintf(stderr, "lsh: expected argument to \"cd\"\n");
            } else if (chdir(args[1]) != 0) {
                perror("lsh");
            }
            continue;
        } else if (strcmp(args[0], "exit") == 0) {
            printf("Exiting lsh...\n");
            break;
        }

        // Obsługa potoków
        int pipe_pos = -1;
        for (int i = 0; args[i] != NULL; i++) {
            if (strcmp(args[i], "|") == 0) {
                pipe_pos = i;
                args[i] = NULL;
                for (int j = 0; j < i; j++) {
                    cmd1[j] = args[j];
                }
                cmd1[pipe_pos] = NULL;

                for (int j = i + 1, k = 0; args[j] != NULL; j++, k++) {
                    cmd2[k] = args[j];
                }
                cmd2[argc - pipe_pos - 1] = NULL;
                break;
            }
        }

        if (pipe_pos != -1) {
            execute_pipe(cmd1, cmd2);
        } else {
            bool background = false;
            if (argc > 0 && strcmp(args[argc - 1], "&") == 0) {
                background = true;
                args[argc - 1] = NULL;
            }
            execute_command(args, background);
        }
    }

    return 0;
}

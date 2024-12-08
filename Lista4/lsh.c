#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* Obsługa zombie */
void sigchld_handler(int sig) {
  while (waitpid(-1, NULL, WNOHANG) > 0);
}

/* Implementacja komendy cd */
int cd(char **command) {
  if (command[1] == NULL) {
    fprintf(stderr, "lsh: oczekiwano argumentu dla \"cd\"\n");
  } else {
    if (chdir(command[1]) != 0) {
      perror("lsh");
    }
  }
  return 1;
}

/* Implementacja komendy exit */
int exit(char **command) {
  return 0;
}

/* Funkcja uruchamiająca program */
int lsh_launch(char **command) {
  pid_t pid = fork();
  if (pid == 0) {
    if (execvp(command[0], command) == -1) {
      perror("lsh");
    }
    exit(EXIT_FAILURE);
  } else if (pid < 0) {
    perror("lsh");
  } else {
    wait(NULL);
  }
  return 1;
}

/* Funkcja wykonująca komendy */
int lsh_execute(char **command) {
  if (command[0] == NULL) return 1;

  if (strcmp(command[0], "cd") == 0) {
    return cd(command);
  } else if (strcmp(command[0], "exit") == 0) {
    return exit(command);
  }
  return lsh_launch(command);
}

/* Funkcja odczytująca linię z stdin */
char *lsh_read_line() {
  char *line = NULL;
  size_t bufsize = 0;

  if (getline(&line, &bufsize, stdin) == -1) {
    free(line);
    return NULL;
  }
  return line;
}

/* Funkcja dzieląca linię na tokeny */
char **lsh_split_line(char *line) {
  int bufsize = 64;
  int position = 0;
  char **tokens = malloc(bufsize * sizeof(char *));
  char *token = strtok(line, " \t\r\n\a");

  while (token != NULL) {
    tokens[position++] = token;
    token = strtok(NULL, " \t\r\n\a");
  }
  tokens[position] = NULL;
  return tokens;
}

/* Główna pętla powłoki */
void lsh_loop(void) {
  char *line;
  char **command;
  int status = 1;

  while (status) {
    printf("> ");
    line = lsh_read_line();
    if (line == NULL) {
      printf("\n");
      break;
    }
    command = lsh_split_line(line);
    status = lsh_execute(command);
    free(line);
    free(command);
  }
}

/* Funkcja main */
int main() {
  signal(SIGCHLD, sigchld_handler);
  lsh_loop();
  return 0;
}
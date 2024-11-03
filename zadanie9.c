#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

void change_stdout(pid_t target_pid, const char *new_output_file) {
    // Otwieramy plik, do którego chcemy przekierować stdout
    int fd = open(new_output_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        exit(EXIT_FAILURE);
    }

    // Dołączamy do procesu
    if (ptrace(PTRACE_ATTACH, target_pid, NULL, NULL) == -1) {
        perror("PTRACE_ATTACH");
        close(fd);
        exit(EXIT_FAILURE);
    }

    // Czekamy na proces, aby był gotowy
    waitpid(target_pid, NULL, 0);

    // Zmiana deskryptora pliku 1 (stdout)
    long ptrace_result = ptrace(PTRACE_POKEUSER, target_pid, sizeof(long) * 1, fd);
    if (ptrace_result == -1) {
        perror("PTRACE_POKEUSER");
        ptrace(PTRACE_DETACH, target_pid, NULL, NULL);
        close(fd);
        exit(EXIT_FAILURE);
    }

    // Odłączamy od procesu
    ptrace(PTRACE_DETACH, target_pid, NULL, NULL);
    close(fd);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <pid> <new_output_file>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    pid_t target_pid = atoi(argv[1]);
    const char *new_output_file = argv[2];

    change_stdout(target_pid, new_output_file);

    printf("Successfully changed stdout of process %d to %s\n", target_pid, new_output_file);
    return 0;
}

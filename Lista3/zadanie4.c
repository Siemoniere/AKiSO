#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf(2, "Error: Wrong amount of data");
        exit();
    }

    int x = atoi(argv[1]);
    int y = atoi(argv[3]);
    char operator = argv[2][0];

    switch (operator) {
        case '+':
            printf(1, "%d\n", x + y);
            break;
        case '-':
            printf(1, "%d\n", x - y);
            break;
        case '*':
            printf(1, "%d\n", x * y);
            break;
        case '/':
            if (y == 0) {
                printf(2, "Error: Do not divide by 0!\n");
                exit();
            }
            printf(1, "%d\n", x / y);
            break;
        default:
            printf(2, "Error: Unknown operator %c\n", operator);
            exit();
    }
    exit();
}

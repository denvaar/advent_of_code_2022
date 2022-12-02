#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {

  FILE* file_ptr = fopen(argv[1], "r");

  if (file_ptr == NULL) {
    fprintf(stderr, "Can't open input file\n");

    return 1;
  }

  char buffer[50];

  int max_so_far[3] = {0, 0, 0};
  int calories = 0;

  while (fgets(buffer, sizeof(buffer), file_ptr) != NULL) {
    if (strcmp(buffer, "\n") == 0) {
      for (int i = 0; i < sizeof(max_so_far); i++) {
        if (calories > max_so_far[i]) {
          max_so_far[i] = calories;
          break;
        }
      }

      calories = 0;

    } else {
      calories += atoi(buffer);
    }
  }

  printf("SOLUTION: %d", max_so_far[0] + max_so_far[1] + max_so_far[2]);

  return 0;
}

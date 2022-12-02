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

  int max_so_far = 0;
  int calories = 0;

  while (fgets(buffer, sizeof(buffer), file_ptr) != NULL) {
    if (strcmp(buffer, "\n") == 0) {
      if (calories > max_so_far) {
        max_so_far = calories;
      }

      calories = 0;

    } else {
      calories += atoi(buffer);
    }
  }

  printf("SOLUTION: %d", max_so_far);

  return 0;
}

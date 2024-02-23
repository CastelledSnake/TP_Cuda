#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define UN_MILLIARD 1000000000

void random_array(int size, int array[]) {
    /* Fill the array with random numbers */
	for (int i=0; i<size; ++i) {
		array[i] = rand();
	}
}


void sum_arrays(int size, int a1[], int a2[], int result[]) {
    /* Sum the two arrays and store the result in the third one */
	for (int i=0; i<size; ++i) {
		result[i] = a1[i] + a2[i];
	}
}


int main(int argc, char *argv[]) {
	int array_size;
	struct timespec t1, t2;
	long t_a1, t_a2, t_add;

	// Check the number of arguments
	if (argc != 2) {
		fprintf(stderr, "usage %s array_size\n", argv[0]);
		return EXIT_FAILURE;
	}
	// Get the size of arrays
	if ((sscanf(argv[1], "%d", &array_size)) == -1) {
		fprintf(stderr, "Impossible to read array_size\n");
		return EXIT_FAILURE;
	}
	srand(time(NULL));

    // Create array 1 and measure the time
	int a1[array_size];
	clock_gettime(CLOCK_REALTIME, &t1);
	random_array(array_size, a1);
	clock_gettime(CLOCK_REALTIME, &t2);
	t_a1 = (t2.tv_sec - t1.tv_sec) / UN_MILLIARD + (t2.tv_nsec - t1.tv_nsec);

    // Create array 2 and measure the time
	int a2[array_size];
	clock_gettime(CLOCK_REALTIME, &t1);
	random_array(array_size, a2);
	clock_gettime(CLOCK_REALTIME, &t2);
	t_a2 = (t2.tv_sec - t1.tv_sec) / UN_MILLIARD + (t2.tv_nsec - t1.tv_nsec);

    // Sum the arrays and measure the time
	int a3[array_size];
	clock_gettime(CLOCK_REALTIME, &t1);
       	sum_arrays(array_size, a1, a2, a3);
	clock_gettime(CLOCK_REALTIME, &t2);
	t_add = (t2.tv_sec - t1.tv_sec) / UN_MILLIARD + (t2.tv_nsec - t1.tv_nsec);

	//fprintf(stdout, "a1 creation : %ld ns\na2 creation : %ld ns\naddition : %ld ns\n", t_a1, t_a2, t_add);
	fprintf(stdout, "%ld;%ld;%ld\n", t_a1, t_a2, t_add);
	return 0;
}

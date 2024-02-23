#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <cuda_runtime.h>
#include <curand.h>
#include <curand_kernel.h>

#define UN_MILLIARD 1000000000

// Compile with command : $nvcc -g --compiler-options -Wall array_addition.cu -o array_addition_par
// With time profiling : $sudo /usr/local/cuda/bin/nvprof <program_name and arguments>

__global__ void random_array(int size, int array[]) {
    /* Generates a random array of integers. into the device memory. */
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	curandState state;
	curand_init(clock64(), tid, 0, &state);

	for (int i=tid; i<size; i+=blockDim.x * gridDim.x) {
		array[i] = curand(&state);
	}
}


__global__ void sum_arrays(int size, int *a1, int *a2, int *result) {
    /* Sums two arrays of integers into the device. */
	for (int i=0; i<size; ++i) {
		result[i] = a1[i] + a2[i];
	}
}


int main(int argc, char *argv[]) {
	int array_size, threads_per_block, nb_blocks;
	//struct timespec t1, t2;
	//long t_a1, t_a2, t_add;
	//long t_add;
	int *d_a1, *d_a2, *d_add;
	int *a1, *a2, *add;
	int max_blocks, max_threads_p_b;
	
	/* Reading all arguments : the size of the arrays to sum, the number of threads per block and the number of blocks to parallelise the execution of the sum.*/
	if (argc != 4) {
		fprintf(stderr, "usage %s array_size threads_per_block nb_blocks\n", argv[0]);
		return EXIT_FAILURE;
	}
	if ((sscanf(argv[1], "%d", &array_size)) == -1) {
		fprintf(stderr, "Impossible to read array_size\n");
		return EXIT_FAILURE;
	}
	if ((sscanf(argv[2], "%d", &threads_per_block)) == -1) {
		fprintf(stderr, "Impossible to read the number of threads per block\n");
		return EXIT_FAILURE;
	}
	if ((sscanf(argv[3], "%d", &nb_blocks)) == -1) {
		fprintf(stderr, "Impossible to read the number of blocks\n");
		return EXIT_FAILURE;
	}
	
	srand(time(NULL));
    // Get capability information about the device.
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, 0);
	max_blocks = deviceProp.maxThreadsPerMultiProcessor / deviceProp.maxThreadsPerBlock;

	// Check if the number of blocks and threads per block fit with the system's capacities.
	if (nb_blocks > max_blocks) {
		fprintf(stderr, "The device can handle %d blocks at max ; %d given\n", max_blocks, nb_blocks);
		return EXIT_FAILURE;
	}
	max_threads_p_b = deviceProp.maxThreadsPerBlock;
	if (threads_per_block > max_threads_p_b) {
		fprintf(stderr, "The device can handle %d threads per block ; %d given\n", max_threads_p_b, threads_per_block);
		return EXIT_FAILURE;
	}
		
	/* ALLOACTING a1 */
	a1 = (int*)malloc(array_size * sizeof(int));
	//clock_gettime(CLOCK_REALTIME, &t1);
	// Allocate device memory for a1.
	cudaMalloc(&d_a1, array_size*sizeof(int));
	// Generate array.
	random_array<<<threads_per_block, nb_blocks>>>(array_size, d_a1);
	//clock_gettime(CLOCK_REALTIME, &t2);
	// Transfer data from device to host for printing.
	/*
	cudaMemcpy(a1, d_a1, array_size*sizeof(int), cudaMemcpyDeviceToHost);
	for (int k=0; k<array_size; k++) {
		fprintf(stdout, "%d ", a1[k]);
	}
	fprintf(stdout, "\n");
	*/
	//t_a1 = (t2.tv_sec - t1.tv_sec) / UN_MILLIARD + (t2.tv_nsec - t1.tv_nsec);
	
	/* ALLOACTING a2 */	
	a2 = (int*) malloc(array_size * sizeof(int));
	//clock_gettime(CLOCK_REALTIME, &t1);
	// Allocate device memory for a2.
	cudaMalloc(&d_a2, array_size*sizeof(int));
	// Generate array.
	random_array<<<threads_per_block, nb_blocks>>>(array_size, d_a2);
	//clock_gettime(CLOCK_REALTIME, &t2);
	// Transfer data from host to device memory.
	/*
	cudaMemcpy(a2, d_a2, array_size*sizeof(int), cudaMemcpyDeviceToHost);
	for (int k=0; k<array_size; k++) {
		fprintf(stdout, "%d ", a2[k]);
	}
	fprintf(stdout, "\n");
	*/
	//t_a2 = (t2.tv_sec - t1.tv_sec) / UN_MILLIARD + (t2.tv_nsec - t1.tv_nsec);
	
	/* ALLOACTING add */
	add = (int*) malloc(array_size * sizeof(int));
	// Allocate device memory for add.
	cudaMalloc(&d_add, array_size*sizeof(int));
	
	/* COMPUTING ADD */
	//clock_gettime(CLOCK_REALTIME, &t1);
	// The development device can handle 2 blocks and 1024 threads per block simultaneously.
       	//sum_arrays<<<max_blocks, max_threads_p_b>>>(array_size, d_a1, d_a2, d_add);
	sum_arrays<<<threads_per_block, nb_blocks>>>(array_size, d_a1, d_a2, d_add);
	//clock_gettime(CLOCK_REALTIME, &t2);
	//t_add = (t2.tv_sec - t1.tv_sec) / UN_MILLIARD + (t2.tv_nsec - t1.tv_nsec);
	// Transfer data from host to device memory.
	/*	
	cudaMemcpy(add, d_add, array_size * sizeof(int), cudaMemcpyDeviceToHost);
	for (int k=0; k<array_size; k++) {
		fprintf(stdout, "%d ", add[k]);
	}
	fprintf(stdout, "\n ");
	*/

	/* GENERAL CLEANUP */
	cudaFree(d_a1);
	cudaFree(d_a2);
	cudaFree(d_add);
	free(a1);
	free(a2);
	free(add);
	
	//fprintf(stdout, "a1 creation : %ld ns\na2 creation : %ld ns\naddition : %ld ns\n", t_a1, t_a2, t_add);
	//fprintf(stdout, "%ld;%ld;%ld\n", t_a1, t_a2, t_add);
	return 0;
}

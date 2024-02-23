#include <stdio.h>
#include <cuda_runtime.h>

int main() {
	int deviceCount;
	cudaGetDeviceCount(&deviceCount);

	if (deviceCount == 0) {
		printf("No CUDA-capable devices detected\n");
		return 0;
	}

	printf("Number of CUDA devices: %d\n", deviceCount);

	for (int i=0; i<deviceCount; ++i) {
		cudaDeviceProp deviceProp;
		cudaGetDeviceProperties(&deviceProp, i);

		printf("\nDevice %d:\n", i);
		printf("  Device name: %s\n", deviceProp.name);
		printf("  Compute capability: %d.%d\n", deviceProp.major, deviceProp.minor);
		printf("  Total global memory: %.2f GB\n", static_cast<float>(deviceProp.totalGlobalMem) / (1024 * 1024 * 1024));
		printf("  Number of multiprocessors: %d\n", deviceProp.multiProcessorCount);
		printf("  Maximum threads per block: %d\n", deviceProp.maxThreadsPerBlock);
		printf("  Maximum threads per multiprocessor: %d\n", deviceProp.maxThreadsPerMultiProcessor);
	}

	return 0;
}

#!/bin/bash

output_file="../measures/c_results/results.txt"

# Clear the existing file or create a new one.
> "$output_file"

for power in {0..20}
do
	inputSize=$((2**power))
	echo "input size = $inputSize." >> "$output_file"
	for expNum in {1..10}
	do
		echo "Running array_addition.c with input size $inputSize for the $expNum time."
		./array_addition_seq "$inputSize" >> "$output_file"
	done
done

echo "Execution completed. Results are in $output_file."

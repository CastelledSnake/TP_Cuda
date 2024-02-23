for repetition in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
	echo "$repetition iteration out of 30"
	for inputSize in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576
	do
		# shellcheck disable=SC2028
		echo "\t$inputSize size"
		for threadNumber in 1 2
		do
			for blockSize in 1 2 4 8 16 32 64 128 256 512 1024
			do
				output_file="../measures/cuda_results/array-add_${inputSize}_${threadNumber}_${blockSize}_${repetition}.csv"
				/usr/local/cuda/bin/nvprof --log-file "$output_file" --csv ./array_addition_par $inputSize $blockSize $threadNumber
			done
		done
	done
done

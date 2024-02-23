import csv


def process_nvprof_csv(input_file: csv):
    with open(input_file, 'r', newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=',', quotechar='"')
        for row in reader:
            if row[0] == "GPU activities":
                if len(row) != 8:
                    print(f"There are {len(row)} columns in {input_file} instead of 8")
                    return 0, 0, 0
                if row[7] == "random_array(int, int*)":
                    min_init_time = float(row[5])
                    max_init_time = float(row[6])
                elif row[7] == "sum_arrays(int, int*, int*, int*)":
                    time_sum = float(row[4])
        try:
            return max_init_time, min_init_time, time_sum
        except UnboundLocalError:
            return 0, 0, 0


def process_all_files(inputs: list[str], output: str):
    no_exploitable_files = []
    with open(output, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=';')
        writer.writerow(['Max_init', 'Min_init', 'Avg_sum'])

        for input_file in inputs:
            max_val, min_val, avg_val = process_nvprof_csv(input_file)
            if max_val == 0 and min_val == 0 and avg_val == 0:
                no_exploitable_files.append(input_file)
            else:
                writer.writerow([max_val, min_val, avg_val])
    return no_exploitable_files


def aggregation(output: str, input_size_max: int, thread_number_max: int, block_size_max: int, repetition_max: int):
    inputs = []
    # Variables are given as powers of 2, but the repetition number is given as the actual number.
    for input_size in range(0, input_size_max):
        for thread_number in range(0, thread_number_max):
            for block_size in range(0, block_size_max):
                for repetition in range(1, repetition_max):
                    inputs.append(baseline + f"{2**input_size}_{2**thread_number}_{2**block_size}_{repetition}.csv")
    corrupted_files = process_all_files(inputs, output)
    print(f"Values successfully exported to {output}, corrupted files: {len(corrupted_files)} out of {len(inputs)} :")
    return corrupted_files


if __name__ == "__main__":
    output_file = "../raw_output.csv"
    baseline = "../cuda_results/array-add_"
    print(aggregation(output_file, 21, 2, 11, 31))

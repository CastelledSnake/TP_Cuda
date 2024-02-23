import csv
from statistics import mean, stdev


def apply_operation(reader: csv.reader, output: str, operation: callable, repetitions: int):
    """
    Apply an operation to data in an input csv file and write the results to another file.
    :param reader: the reader on an input csv file.
    :param output: the name of the output file.
    :param operation: the operation to apply to the input.
    :param repetitions: the number of rows to read before applying the operation.
    :return: None
    """
    with open(output, 'w', newline='') as output_file:
        writer = csv.writer(output_file, delimiter=';')
        writer.writerow(['Max_init', 'Min_init', 'Avg_sum'])

        maxima_init, minima_init, averages_sum, counter = [], [], [], 0
        for row in reader:
            maxima_init.append(float(row[0]))
            minima_init.append(float(row[1]))
            averages_sum.append(float(row[2]))
            counter += 1
            if counter == repetitions:
                writer.writerow([operation(maxima_init), operation(minima_init), operation(averages_sum)])
                maxima_init, minima_init, averages_sum, counter = [], [], [], 0


def apply_all_operations(l_input: str, outputs: list[str], operations: list[callable], repetitions: int):
    """
    Apply a list of operations to a same input file, and exports the results into some output files.
    :param l_input: the name of the input file.
    :param outputs: the list of the names of the output files.
    :param operations: the list of operations to apply to the input.
    :param repetitions: the number of rows to read before applying the operation.
    :return: None
    """
    if len(outputs) != len(operations):
        raise ValueError("The number of outputs and operations must be the same")
    for op_index in range(len(operations)):
        with open(l_input, 'r', newline='') as csvfile:
            reader = csv.reader(csvfile, delimiter=';')
            next(reader)  # Skip the header
            apply_operation(reader, outputs[op_index], operations[op_index], repetitions)


if __name__ == "__main__":
    repetition_number = 30
    input_file = "../raw_output.csv"
    output_files = ["../averages.csv", "../std_devs.csv"]
    stats_operations = [mean, stdev]
    apply_all_operations(input_file, output_files, stats_operations, repetition_number)
    print(f"Values successfully exported to {output_files} using {output_files}")

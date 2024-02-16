import pandas as pd


def get_null_count_columns(data_frame):
    null_counts_acc = {}
    # Iterate through each column
    for column in data_frame.columns:
        # Count null values for each feature
        curr_null_count_acc = data_frame[column].isnull().sum()
        if curr_null_count_acc > 0:
            null_counts_acc[column] = [curr_null_count_acc]
    return null_counts_acc

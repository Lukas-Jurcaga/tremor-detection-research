import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import zscore


def get_null_count_columns(data_frame):
    null_counts_acc = {}
    # Iterate through each column
    for column in data_frame.columns:
        # Count null values for each feature
        curr_null_count_acc = data_frame[column].isnull().sum()
        if curr_null_count_acc > 0:
            null_counts_acc[column] = [curr_null_count_acc]
    return null_counts_acc


def null_count_plots(df, starting_col_index, name, y_fontsize=10, x_fontsize=10):
    null_counts = get_null_count_columns(df.iloc[:, starting_col_index:])
    null_df = pd.DataFrame(data=null_counts, index=['Null Counts ' + name])

    # Plots null counts on bar graph
    for column in null_df.columns:
        plt.barh(column, null_df[column].iloc[0], label=column)

    plt.title('Null Values for ' + name + ' Data')
    plt.xlabel('Number of Records')
    plt.ylabel('Features')
    plt.xticks(fontsize=x_fontsize)
    plt.yticks(fontsize=y_fontsize)
    plt.show()

    print("Number of features with at least one Null value for " + name + " data: " + str(len(null_df.columns)))
    return null_df


def z_normalise_df(df, normalise_from_index):
    z_scores = zscore(df.iloc[:, normalise_from_index:].astype(float))
    # Create a new DataFrame with Z-scores
    norm_df = pd.DataFrame(z_scores, columns=df.columns[normalise_from_index:])
    norm_df = pd.concat([df.iloc[:, :normalise_from_index], norm_df], axis=1)
    # deleted any null values
    norm_null_count = get_null_count_columns(norm_df.iloc[:, normalise_from_index:])
    norm_df = norm_df.drop(columns=list(norm_null_count.keys()))
    return norm_df




import pandas as pd

corr_threshold = 0.5


def get_corr_redundant_features(correlation_matrix, target_class_correlation):
    corr_redundant_features = []
    for i in range(len(correlation_matrix.columns)):
        for j in range(i):
            if not (target_class_correlation.columns[j] in corr_redundant_features):
                if abs(correlation_matrix.iloc[j, i]) > corr_threshold:
                    if abs(target_class_correlation.iloc[0, j]) > abs(target_class_correlation.iloc[0, i]):
                        corr_redundant_features.append(target_class_correlation.columns[i])
                        break
                    else:
                        corr_redundant_features.append(target_class_correlation.columns[j])

    return corr_redundant_features

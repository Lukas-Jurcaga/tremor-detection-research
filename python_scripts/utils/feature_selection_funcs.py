import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_selection import RFECV
from sklearn.model_selection import GroupKFold


def get_feature_importance(features, target):
    random_forest_model = RandomForestClassifier()
    random_forest_model.fit(features, target)
    return random_forest_model.feature_importances_


# Get the best features based on their importance score
def get_fi_best_features(features, feature_importance, fi_threshold=0):
    best_features = []

    for i in range(len(feature_importance)):
        if feature_importance[i] > fi_threshold:
            best_features.append(features.columns[i])

    return best_features


def get_corr_redundant_features(df, target_class_col, corr_threshold=0.5):
    df_corr = df.corr()
    correlation_matrix = df_corr.drop(columns=[target_class_col])
    target_class_correlation = correlation_matrix.iloc[[0]].copy()
    correlation_matrix = correlation_matrix.drop(correlation_matrix.index[0])

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


def get_rfecv_selected_features(model, features, target, id_groupings, groupk_folds):
    # Initialize GroupKFold with the number of splits
    gkf = GroupKFold(n_splits=groupk_folds)

    # Initialize RFECV with selected model and GroupKFold
    rfecv = RFECV(estimator=model, cv=gkf)

    # Fit RFECV to the data
    rfecv.fit(features, target, groups=id_groupings)

    # Get the selected features
    return features.columns[rfecv.support_]

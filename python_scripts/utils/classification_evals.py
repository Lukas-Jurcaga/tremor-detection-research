import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix, make_scorer
from sklearn.model_selection import GroupKFold, cross_val_score


def specificity_score(y_true, y_pred):
    tn, fp, _, _ = confusion_matrix(y_true, y_pred).ravel()
    return tn / (tn + fp)


specificity_scorer = make_scorer(specificity_score)
scoring_methods = {'Accuracy': 'accuracy', 'Precision': 'precision_macro', 'Sensitivity': 'recall_macro',
                   'Specificity': specificity_scorer,
                   'F1': 'f1_macro'}


def cross_val_model(features, target, model, id_groupings, groupk_folds, print_scores=False):
    # Initialize GroupKFold with the number of splits
    gkf = GroupKFold(n_splits=groupk_folds)
    results = {}

    # Perform cross-validation with GroupKFold
    for score_method_key in scoring_methods.keys():
        cv_scores = cross_val_score(model, features, target, cv=gkf, groups=id_groupings,
                                    scoring=scoring_methods[score_method_key])
        # Print cross-validation scores
        if print_scores:
            print("Cross-validated mean " + score_method_key + " score:", cv_scores.mean())
        results[score_method_key] = cv_scores.mean()
    return results

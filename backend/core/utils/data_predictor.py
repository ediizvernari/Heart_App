import joblib
import pandas as pd
from datetime import datetime

from backend.config import ML_MODELS_DIR

xgb_model = joblib.load(ML_MODELS_DIR / "xgb_calibrated.joblib")
kmeans_model = joblib.load(ML_MODELS_DIR / "kmeans_model_modif.pkl")
feature_scaler = joblib.load(ML_MODELS_DIR / "feature_scaler_modif.pkl")
cluster_scaler = joblib.load(ML_MODELS_DIR / "cluster_scaler_modif.pkl")

def calculate_age(birth_date:str) -> int:
    birth_date = pd.to_datetime(birth_date)
    today = datetime.today()
    age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
    return age

def calculate_bmi(weight: int, height: int) -> float:
    return weight / ((height / 100) ** 2)

def build_model_input_features_for_prediction(user_info: dict) -> dict:
    age = calculate_age(user_info["birth_date"])
    bmi = calculate_bmi(user_info["weight"], user_info["height"])

    return {
        "age": age,
        "ap_hi": user_info["ap_hi"],
        "ap_lo": user_info["ap_lo"],
        "cholesterol": user_info["cholesterol_level"],
        "BMI": bmi
    }
 
def format_cvd_risk_percentage(cvd_risk: float) -> str:
    risk_percentage = cvd_risk * 100
    return f"{risk_percentage:.2f}"

def predict_probability_of_having_a_cvd(entry):
    expected_columns = ['age', 'ap_hi', 'ap_lo', 'cholesterol', 'BMI']
    features = ['age', 'ap_hi', 'ap_lo', 'cholesterol', 'BMI']

    if not all (column in entry for column in expected_columns):
        return (f"[ERROR] Entry must contain the following columns: {expected_columns}")
    
    entry_df = pd.DataFrame([entry])

    entry_df[features] = feature_scaler.transform(entry_df[features])

    cluster = kmeans_model.predict(entry_df[features])
    entry_df['Cluster'] = cluster
    entry_df['Cluster'] = cluster_scaler.transform(entry_df[['Cluster']])

    predicted_probability = xgb_model.predict_proba(entry_df[features + ['Cluster']])[0]
    probability_of_having_a_cvd = predicted_probability[1]
    formated_cvd_risk = format_cvd_risk_percentage(probability_of_having_a_cvd)

    return formated_cvd_risk

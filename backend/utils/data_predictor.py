# XGB trb instalat cu pip si joblib la fel si pandas
import xgboost as xgb
import joblib
import pandas as pd
from datetime import datetime

#TODO :Rename file names so they are more professional
#TODO: In case of no modifications needed keep the old files without the _modif in their names because they do not include the standard dev
xgb_model = xgb.XGBClassifier()
xgb_model.load_model('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\xgb_model_nebunie.json')

kmeans_model = joblib.load('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\kmeans_model_modif.pkl')
feature_scaler = joblib.load('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\feature_scaler_modif.pkl')
cluster_scaler = joblib.load('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\cluster_scaler_modif.pkl')

def calculate_age(birth_date:str) -> int:
    birth_date = pd.to_datetime(birth_date)
    today = datetime.today()
    age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
    return age

def calculate_bmi(weight: int, height: int) -> float:
    return weight / ((height / 100) ** 2)



MEAN_HI = 126.0
MEAN_LO =  81.0
C_HI    =  16.0
C_LO    =  11.0

def piecewise_dev(value: float, mean: float, c: float, p_small: float = 0.8, p_large: float = 1.5) -> float:

    d = abs(value - mean)
    if d <= c:
        return d**p_small
    return (c**p_small) + ((d - c)**p_large)

def calculate_deviation_for_ap_hi(ap_hi: int) -> float:
    return piecewise_dev(ap_hi, MEAN_HI, C_HI)

def calculate_deviation_for_ap_lo(ap_lo: int) -> float:
    return piecewise_dev(ap_lo, MEAN_LO, C_LO)

def build_model_input_features_for_prediction(user_info: dict) -> dict:
    age = calculate_age(user_info["birth_date"])
    bmi = calculate_bmi(user_info["weight"], user_info["height"])
    ap_hi_pw = calculate_deviation_for_ap_hi(user_info["ap_hi"])
    ap_lo_pw = calculate_deviation_for_ap_lo(user_info["ap_lo"])

    return {
        "age":         age,
        "ap_hi_pw":    ap_hi_pw,
        "ap_lo_pw":    ap_lo_pw,
        "cholesterol": user_info["cholesterol_level"],
        "BMI":         bmi
    }
 
def format_cvd_risk_percentage(cvd_risk: float) -> str:
    risk_percentage = cvd_risk * 100
    return f"{risk_percentage:.2f}"

def predict_probability_of_having_a_cvd(entry):
    expected_columns = ['age', 'ap_hi_pw', 'ap_lo_pw', 'cholesterol', 'BMI']
    features = ['age', 'ap_hi_pw', 'ap_lo_pw', 'cholesterol', 'BMI']

    if not all (column in entry for column in expected_columns):
        return (f"Entry must contain the following columns: {expected_columns}")
    
    entry_df = pd.DataFrame([entry])

    entry_df[features] = feature_scaler.transform(entry_df[features])

    cluster = kmeans_model.predict(entry_df[features])
    entry_df['Cluster'] = cluster
    entry_df['Cluster'] = cluster_scaler.transform(entry_df[['Cluster']])

    predicted_probability = xgb_model.predict_proba(entry_df[features + ['Cluster']])[0]
    probability_of_having_a_cvd = predicted_probability[1]
    formated_cvd_risk = format_cvd_risk_percentage(probability_of_having_a_cvd)

    return formated_cvd_risk

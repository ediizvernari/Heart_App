# XGB trb instalat cu pip si joblib la fel si pandas
import xgboost as xgb
import joblib
import pandas as pd
from datetime import datetime


xgb_model = xgb.XGBClassifier()
xgb_model.load_model('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\xgb_model.json')

kmeans_model = joblib.load('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\kmeans_model.pkl')
feature_scaler = joblib.load('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\feature_scaler.pkl')
cluster_scaler = joblib.load('c:\\Users\\ediiz\\Desktop\\Heart_App\\backend\\utils\\cluster_scaler.pkl')

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
 

def predict_probability_of_having_a_cvd(entry):
    expected_columns = ['age', 'ap_hi', 'ap_lo', 'cholesterol', 'BMI']
    features = ['age', 'ap_hi', 'ap_lo', 'cholesterol', 'BMI']

    if not all (column in entry for column in expected_columns):
        return (f"Entry must contain the following columns: {expected_columns}")
    
    entry_df = pd.DataFrame([entry])

    entry_df[features] = feature_scaler.transform(entry_df[features])

    cluster = kmeans_model.predict(entry_df[features])
    entry_df['Cluster'] = cluster
    entry_df['Cluster'] = cluster_scaler.transform(entry_df[['Cluster']])

    predicted_probability = xgb_model.predict_proba(entry_df[features + ['Cluster']])[0]
    probability_of_having_a_cvd = predicted_probability[1]

    return probability_of_having_a_cvd * 100

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

 

def predict(entry):
    expected_columns = ['age', 'ap_hi', 'ap_lo', 'cholesterol', 'BMI']
    features = ['age', 'ap_hi', 'ap_lo', 'cholesterol', 'BMI']

    #Check if the entry contains the required columns
    if not all (column in entry for column in expected_columns):
        return (f"Entry must contain the following columns: {expected_columns}")
    
    #Convert the entry to a DataFrame
    entry_df = pd.DataFrame([entry])

    #Scale the features
    entry_df[features] = feature_scaler.transform(entry_df[features])

    #Predict the cluster and scale it
    cluster = kmeans_model.predict(entry_df[features])
    entry_df['Cluster'] = cluster
    entry_df['Cluster'] = cluster_scaler.transform(entry_df[['Cluster']])

    #Predict the risk as a percentage 
    predicted_probability = xgb_model.predict_proba(entry_df[features + ['Cluster']])[0]
    probability_of_having_a_cvd = predicted_probability[1]

    #Return the probability of having a cardiovascular disease as a percentage
    return probability_of_having_a_cvd * 100

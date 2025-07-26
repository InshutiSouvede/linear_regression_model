from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, Any
import joblib
import pandas as pd
import numpy as np
import uvicorn
import os

# Initialize FastAPI app
app = FastAPI(
    title="Employee Salary Prediction API",
    description="API for predicting employee monthly salary based on work patterns and performance metrics",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the trained model and feature names
try:
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(base_dir, 'best_model.pkl')
    feature_names_path = os.path.join(base_dir, 'feature_names.pkl')
    print("the path is ", feature_names_path, model_path)
    model = joblib.load(model_path)
    feature_names = joblib.load(feature_names_path)
    print("Model and feature names loaded successfully")
    # model = joblib.load('api/best_model.pkl')
    # feature_names = joblib.load('api/feature_names.pkl')
    # print("Model and feature names loaded successfully")
except FileNotFoundError as e:
    print(f"Error loading model files: {e}")
    print("Please ensure 'best_model.pkl' and 'feature_names.pkl' are in the same directory")
    model = None
    feature_names = None

# Valid job titles and education levels
valid_job_titles = [
    'Specialist', 'Developer', 'Analyst', 'Manager', 'Technician', 'Engineer', 'Consultant'
]
valid_education_levels = ['High School', 'Bachelor', 'Master', 'PhD']

# Pydantic model for input validation
class EmployeeData(BaseModel):
    Age: int = Field(..., ge=18, le=70, description="Employee age (18-70)")
    Job_Title: str = Field(..., description="Job title")
    Education_Level: str = Field(..., description="Education level")
    Performance_Score: int = Field(..., ge=1, le=5, description="Performance score (1-5)")
    Work_Hours_Per_Week: float = Field(..., ge=10, le=80, description="Work hours per week (10-80)")
    Projects_Handled: int = Field(..., ge=0, le=50, description="Number of projects handled (0-50)")
    Overtime_Hours: float = Field(..., ge=0, le=200, description="Overtime hours per year (0-200)")
    Sick_Days: int = Field(..., ge=0, le=50, description="Sick days taken (0-50)")
    Team_Size: int = Field(..., ge=1, le=50, description="Team size (1-50)")
    Promotions: int = Field(..., ge=0, le=20, description="Number of promotions (0-20)")
    
    @validator("Job_Title")
    def validate_job_title(cls, v):
        if v not in valid_job_titles:
            raise ValueError(f"Job title must be one of: {', '.join(valid_job_titles)}")
        return v

    @validator("Education_Level")
    def validate_education_level(cls, v):
        if v not in valid_education_levels:
            raise ValueError(f"Education level must be one of: {', '.join(valid_education_levels)}")
        return v

    class Config:
        schema_extra = {
            "example": {
                "Age": 35,
                "Job_Title": "Manager",
                "Education_Level": "Bachelor",
                "Performance_Score": 4,
                "Work_Hours_Per_Week": 40,
                "Projects_Handled": 10,
                "Overtime_Hours": 20,
                "Sick_Days": 5,
                "Team_Size": 10,
                "Promotions": 2
            }
        }

# Response model
class SalaryPredictionResponse(BaseModel):
    salary: float = Field(..., description="Predicted monthly salary")
    confidence_interval: Optional[tuple] = Field(None, description="95% confidence interval (if available)")
    model_used: str = Field(..., description="Name of the model used for prediction")
    input_summary: Dict[str, Any] = Field(..., description="Summary of input features")

# Welcome endpoint
@app.get("/", tags=["Welcome"])
async def root():
    return {"message": "Welcome to Employee Salary Prediction API!"}

# Prediction endpoint
@app.post("/predict", response_model=SalaryPredictionResponse, tags=["Prediction"])
async def predict_salary(request: EmployeeData):
    if model is None or feature_names is None:
        raise HTTPException(
            status_code=500, 
            detail="Model not loaded. Please ensure model files are available."
        )
    try:
        # Prepare input data
        input_data = pd.DataFrame([request.dict()])
        # Ensure all required features are present
        for feature in feature_names:
            if feature not in input_data.columns:
                input_data[feature] = 0
        input_data = input_data[feature_names]
        input_array = input_data.values
        # Make prediction
        prediction = model.predict(input_array)[0]
        # Confidence interval for ensemble models
        confidence_interval = None
        if hasattr(model, 'estimators_'):
            predictions = [estimator.predict(input_array)[0] for estimator in model.estimators_]
            std_dev = np.std(predictions)
            confidence_interval = (
                max(0, prediction - 1.96 * std_dev),
                prediction + 1.96 * std_dev
            )
        # Prepare response
        response = SalaryPredictionResponse(
            salary=float(prediction),
            confidence_interval=confidence_interval,
            model_used=type(model).__name__,
            input_summary=request.dict()
        )
        return response
    except Exception as e:
        raise HTTPException(
            status_code=400, 
            detail=f"Error making prediction: {str(e)}"
        )

# Run the application
if __name__ == "__main__":
    uvicorn.run(
        "main2:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
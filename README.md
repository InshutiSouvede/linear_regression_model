# Employee Salary Prediction - ML Project

## 🌱 Mission Statement

My mission is to improve mental health in this era of technology. By enabling fair and data-driven salary predictions, this project aims to reduce workplace stress and promote well-being through transparency and informed decision-making.


## 🎯 Project Overview

This project provides a complete machine learning pipeline for predicting monthly salary based on work patterns, performance metrics, and personal attributes. It includes:

- **Exploratory Data Analysis (EDA):** Interactive visualizations to understand employee data.
- **Feature Engineering:** Smart selection and transformation of features for salary prediction.
- **Model Training & Comparison:** Linear Regression, Decision Tree, and Random Forest
- **API Integration:** FastAPI-based REST API for real-time salary prediction.
- **Flutter App:** A cross-platform mobile app for user-friendly salary prediction.
- **Jupyter Notebook:** For interactive model development and experimentation.

---

## 📁 Project Structure

```
employee_salary_prediction/
│
├── data/
│   └── employee_data.csv          # Main dataset
│
├── api/
│   ├── main.py                    # FastAPI salary prediction API
│   └── best_model.pkl             # The model to use
│   └── featur_names.pkl           # A list of columns to consider while predicting
│
├── salary_prediction_app/
│   └── lib/
│       └── main.dart              # Flutter app for salary prediction
├── requirements.txt               # Python dependencies
├── employee_salary.ipynb          # The notebook for training the models
├── start.py                       # The starter file for this project (for deployment purposes)
└── README.md                      # Project documentation
```

---

## 🚀 How to Use This Project

### 1. **Setup Python Environment**

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. **Explore and Train Models**

- Open `notebooks/exploratory_analysis.ipynb` in Jupyter Notebook or VS Code.
- Run the notebook to explore data, engineer features, train models, and save the best model.

### 3. **Run the Main Script**

```bash
python main.py
```
- This will preprocess data, train models, compare performance, and save the best model and scaler in `models/`.

### 4. **Start the API Server**

```bash
cd api
uvicorn main:app --reload
```
- The API will be available at `http://localhost:8000`.
- Use `/docs` for interactive Swagger UI.

### 5. **Use the Flutter App**

- Navigate to `salary_prediction_app/` and run:
  ```bash
  flutter pub get
  flutter run
  ```
- The app connects to the API and provides a user-friendly interface for salary prediction.

### 6. **Make Predictions via API**

- Send a POST request to `/predict` with employee data using Thunder Client, Postman, or the Flutter app.
- Example payload:
  ```json
  {
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
  ```

---

## 🧩 Key Features

- **Comprehensive EDA:** 10+ visualizations for deep data understanding.
- **Feature Engineering:** Smart selection for salary prediction.
- **Model Optimization:** Gradient descent and hyperparameter tuning.
- **Model Comparison:** Linear Regression, Decision Tree, Random Forest.
- **Production Ready:** Saved models and prediction pipeline.
- **API Ready:** FastAPI endpoints for real-time prediction.
- **Flutter App:** Modern, responsive UI for salary prediction.

---

## 📚 Next Steps

1. Train and evaluate models using the notebook or main script.
2. Start the API server for real-time predictions.
3. Use the Flutter app or API endpoints to predict salaries.
4. Explore visualizations in the `visualizations/` folder.

---

## 💡 Notes

- Place your dataset in `data/employee_data.csv`.
- For API and app integration, ensure the server is running and accessible.
- For Android emulator, use `http://10.0.2.2:8000` instead of `localhost`.

---

**Enjoy exploring and predicting employee salaries with this end-to-end ML solution!**
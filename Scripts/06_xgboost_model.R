# =====================================================
# Alberta Export Diversification Project
# XGBoost Model
# =====================================================

library(data.table)
library(dplyr)
library(caret)
library(xgboost)

# -----------------------------------------------------
# Load Data
# -----------------------------------------------------

model_data_ab <- fread(
  "Data/Processed/model_data_alberta.csv"
)

# -----------------------------------------------------
# Select Variables
# -----------------------------------------------------

model_ml <- model_data_ab %>%
  select(
    log_trade_value,
    hs4,
    log_gdp_o,
    log_gdp_d,
    log_pop_o,
    log_pop_d,
    log_dist,
    contig,
    comlang_off,
    fta_wto,
    log_ab_exports
  )

# -----------------------------------------------------
# Remove Missing Values
# -----------------------------------------------------

model_ml <- na.omit(model_ml)

# -----------------------------------------------------
# Train/Test Split
# -----------------------------------------------------

set.seed(123)

train_index <- createDataPartition(
  model_ml$log_trade_value,
  p = 0.8,
  list = FALSE
)

train_data <- model_ml[train_index, ]
test_data  <- model_ml[-train_index, ]

# -----------------------------------------------------
# Create Matrices
# -----------------------------------------------------

x_train <- as.matrix(
  train_data %>%
    select(-log_trade_value)
)

y_train <- train_data$log_trade_value

x_test <- as.matrix(
  test_data %>%
    select(-log_trade_value)
)

y_test <- test_data$log_trade_value

# -----------------------------------------------------
# DMatrix Objects
# -----------------------------------------------------

dtrain <- xgb.DMatrix(
  data = x_train,
  label = y_train
)

dtest <- xgb.DMatrix(
  data = x_test,
  label = y_test
)



# -----------------------------------------------------
# Train Model
# -----------------------------------------------------

set.seed(123)

xgb_model <- xgboost(
  x = x_train,
  y = y_train,
  
  objective = "reg:squarederror",
  
  nrounds = 300,
  
  max_depth = 6,
  
  learning_rate = 0.05,
  
  subsample = 0.8,
  
  colsample_bytree = 0.8
)


# -----------------------------------------------------
# Predict
# -----------------------------------------------------

pred_xgb <- predict(
  xgb_model,
  x_test
)

# -----------------------------------------------------
# Evaluation
# -----------------------------------------------------

rmse_xgb <- RMSE(
  pred_xgb,
  y_test
)

mae_xgb <- MAE(
  pred_xgb,
  y_test
)

r2_xgb <- R2(
  pred_xgb,
  y_test
)

cat("\n")
cat("=====================================\n")
cat("XGBoost Performance\n")
cat("=====================================\n")
cat("RMSE :", rmse_xgb, "\n")
cat("MAE  :", mae_xgb, "\n")
cat("R²   :", r2_xgb, "\n")
cat("=====================================\n")

# -----------------------------------------------------
# Feature Importance
# -----------------------------------------------------

importance_matrix <- xgb.importance(
  feature_names = colnames(x_train),
  model = xgb_model
)

print(
  importance_matrix
)

# -----------------------------------------------------
# Save Feature Importance 
# -----------------------------------------------------

fwrite(
  importance_matrix,
  "Output/xgb_feature_importance.csv"
)

# -----------------------------------------------------
# Save Model
# -----------------------------------------------------

xgb.save(
  xgb_model,
  "Output/xgb_model.model"
)

# =====================================================
# Alberta Export Diversification Project
# Random Forest Model
# =====================================================

# -----------------------------------------------------
# Libraries
# -----------------------------------------------------

library(data.table)
library(dplyr)
library(caret)
library(randomForest)

# -----------------------------------------------------
# Load Alberta Modeling Dataset
# -----------------------------------------------------

model_data_ab <- fread(
  "Data/Processed/model_data_alberta.csv"
)



# -----------------------------------------------------
# Select Modeling Variables
# -----------------------------------------------------

model_ml <- model_data_ab %>%
  select(
    
    # Target
    log_trade_value,
    
    # Product
    hs4,
    
    # Economic variables
    log_gdp_o,
    log_gdp_d,
    
    log_pop_o,
    log_pop_d,
    
    # Geography
    log_dist,
    
    # Trade relationship
    contig,
    comlang_off,
    fta_wto,
    
    # Alberta specialization
    log_ab_exports
    
  )

# -----------------------------------------------------
# Train/Test Split
# -----------------------------------------------------

set.seed(123)

train_index <- createDataPartition(
  model_ml$log_trade_value,
  p = 0.80,
  list = FALSE
)

train_data <- model_ml[train_index, ]
test_data  <- model_ml[-train_index, ]

# -----------------------------------------------------
# Convert HS4 to Factor
# -----------------------------------------------------

train_data$hs4 <- as.factor(train_data$hs4)
test_data$hs4  <- as.factor(test_data$hs4)

# -----------------------------------------------------
# Remove Missing Values
# -----------------------------------------------------

train_data_rf <- na.omit(train_data)
test_data_rf  <- na.omit(test_data)

cat("Training rows:", nrow(train_data_rf), "\n")
cat("Testing rows :", nrow(test_data_rf), "\n")

# -----------------------------------------------------
# Train Random Forest
# -----------------------------------------------------

set.seed(123)

rf_model <- randomForest(
  log_trade_value ~ .,
  data = train_data_rf,
  ntree = 300,
  importance = TRUE
)

# -----------------------------------------------------
# Predict
# -----------------------------------------------------

pred_rf <- predict(
  rf_model,
  newdata = test_data_rf
)

# -----------------------------------------------------
# Evaluation Metrics
# -----------------------------------------------------

rmse_rf <- RMSE(
  pred_rf,
  test_data_rf$log_trade_value
)

mae_rf <- MAE(
  pred_rf,
  test_data_rf$log_trade_value
)

r2_rf <- R2(
  pred_rf,
  test_data_rf$log_trade_value
)

cat("\n")
cat("================================================\n")
cat("Random Forest Performance\n")
cat("================================================\n")
cat("RMSE :", rmse_rf, "\n")
cat("MAE  :", mae_rf, "\n")
cat("R²   :", r2_rf, "\n")
cat("================================================\n")

# -----------------------------------------------------
# Variable Importance Plot
# -----------------------------------------------------

png(
  "Figures/random_forest_feature_importance.png",
  width = 1200,
  height = 800
)

varImpPlot(
  rf_model,
  main = "Random Forest Feature Importance"
)

dev.off()

# -----------------------------------------------------
# Save Model
# -----------------------------------------------------

saveRDS(
  rf_model,
  "Output/random_forest_model.rds"
)

# -----------------------------------------------------
# Save Metrics
# -----------------------------------------------------

rf_metrics <- data.frame(
  Model = "Random Forest",
  RMSE = rmse_rf,
  MAE = mae_rf,
  R2 = r2_rf
)
 
fwrite(
  rf_metrics,
  "Output/random_forest_metrics.csv"
)

cat("\nModel saved successfully.\n")

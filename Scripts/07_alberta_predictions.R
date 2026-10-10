# =====================================================
# Alberta Export Diversification Project
# Alberta Export Opportunity Predictions
# =====================================================

library(data.table)
library(dplyr)
library(tidyr)
library(xgboost)

# -----------------------------------------------------
# Load Trained XGBoost Model
# -----------------------------------------------------

xgb_model <- xgb.load(
  "Output/xgb_model.model"
)

# -----------------------------------------------------
# Load Alberta Specialization Data 
# -----------------------------------------------------

alberta_spec <- fread(
  "Data/Raw/alberta_specialization.csv"
)

alberta_spec <- alberta_spec %>%
  mutate(
    hs4 = sprintf("%04d", as.numeric(hs4)),
    
    alberta_export_value =
      as.numeric(
        gsub(",", "", alberta_export_value)
      ),
    
    log_ab_exports =
      log1p(alberta_export_value)
  )

# -----------------------------------------------------
# Load Clean Trade Dataset
# -----------------------------------------------------

model_data <- fread(
  "Data/Processed/model_data_clean.csv"
)

# -----------------------------------------------------
# Create Log Variables
# -----------------------------------------------------

model_data <- model_data %>%
  mutate(
    log_gdp_d = log1p(gdp_d),
    log_pop_d = log1p(pop_d),
    log_dist  = log1p(dist)
  )

# -----------------------------------------------------
# Prediction Countries
# -----------------------------------------------------

prediction_countries <- c(
  "USA",
  "CHN",
  "JPN",
  "KOR",
  "GBR",
  "MEX",
  "NLD",
  "IND",
  "SGP",
  "HKG",
  "PER"
)

# -----------------------------------------------------
# Destination Features
# -----------------------------------------------------

importer_features <- model_data %>%
  filter(
    importer %in% prediction_countries
  ) %>%
  select(
    importer,
    log_gdp_d,
    log_pop_d,
    log_dist,
    contig,
    comlang_off,
    fta_wto
  ) %>%
  distinct(importer, .keep_all = TRUE)

# -----------------------------------------------------
# Alberta Characteristics
# -----------------------------------------------------

alberta_gdp <- 367700000000

alberta_pop <- 5050000

log_gdp_o <- log1p(alberta_gdp)

log_pop_o <- log1p(alberta_pop)

# -----------------------------------------------------
# Create Prediction Dataset
# -----------------------------------------------------
prediction_data <- tidyr::crossing(
  alberta_spec,
  importer_features
)

# -----------------------------------------------------
# Prepare Model Inputs
# -----------------------------------------------------

prediction_ml <- prediction_data %>%
  transmute(
    
    hs4 = as.numeric(hs4),
    
    log_gdp_o = log_gdp_o,
    log_gdp_d = log_gdp_d,
    
    log_pop_o = log_pop_o,
    log_pop_d = log_pop_d,
    
    log_dist = log_dist,
    
    contig = contig,
    comlang_off = comlang_off,
    fta_wto = fta_wto,
    
    log_ab_exports = log_ab_exports
    
  )

# -----------------------------------------------------
# Generate Predictions
# -----------------------------------------------------

x_pred <- as.matrix(prediction_ml)

prediction_data$opportunity_score <-
  predict(
    xgb_model,
    x_pred
  )

# -----------------------------------------------------
# Destination Ranking
# -----------------------------------------------------

destination_ranking <- prediction_data %>%
  group_by(importer) %>%
  summarise(
    opportunity_score =
      sum(opportunity_score)
  ) %>%
  arrange(
    desc(opportunity_score)
  )

print(destination_ranking)

# -----------------------------------------------------
# Top 5 Products Per Destination
# -----------------------------------------------------

top_products <- prediction_data %>%
  group_by(importer) %>%
  arrange(
    desc(opportunity_score)
  ) %>%
  slice_head(n = 5) %>%
  ungroup()

# -----------------------------------------------------
# Save Outputs
# -----------------------------------------------------

fwrite(
  destination_ranking,
  "Output/predicted_destination_ranking.csv"
)

fwrite(
  top_products,
  "Output/predicted_top_products.csv"
)

cat("\n")
cat("=====================================\n")
cat("Predictions Complete\n")
cat("=====================================\n")
cat(
  "Destination ranking saved to:\n",
  "Output/predicted_destination_ranking.csv\n"
)
cat(
  "Top products saved to:\n",
  "Output/predicted_top_products.csv\n"
)
cat("=====================================\n")

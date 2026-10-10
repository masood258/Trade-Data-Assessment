library(data.table)
library(dplyr)

# =====================================================
# BUILD MODEL DATASET FOR ALBERTA EXPORT OPPORTUNITY
# =====================================================

# Contains exporter-importer-product trade values
# at the HS4 product level.
# -----------------------------
# Load processed trade data
# -----------------------------

trade_hs4 <- fread(
  "Data/Processed/trade_hs4.csv"
)

# -----------------------------
# Load gravity data
# -----------------------------
# Gravity variables describe economic size,
# distance, population, trade agreements,
# and other country-pair characteristics.

gravity <- fread(
  "Data/Raw/Gravity_csv_V202211/Gravity_V202211.csv"
)


# Keep only variables needed for modelling

gravity_small <- gravity %>%
  select(
    year,
    iso3_o,
    iso3_d,
    dist,
    contig,
    comlang_off,
    gdp_o,
    gdp_d,
    pop_o,
    pop_d,
    gdpcap_o,
    gdpcap_d,
    fta_wto
  ) %>%
  filter(year == 2020) %>%
  rename(
    exporter = iso3_o,
    importer = iso3_d
  )

# Remove any duplicate exporter-importer pairs

gravity_small <- gravity_small %>%
  distinct(
    exporter,
    importer,
    .keep_all = TRUE
  )
gravity_small %>%
  count(exporter, importer) %>%
  filter(n > 1)

# -----------------------------
# -----------------------------
# Merge trade and gravity data
# -----------------------------
# Add gravity variables to each trade observation.

model_data <- trade_hs4 %>%
  left_join(
    gravity_small,
    by = c(
      "exporter",
      "importer"
    )
  )


# Remove observations where gravity data
# could not be matched.

model_data <- model_data %>%
  filter(
    !is.na(dist)
  )

# Standardize HS4 format
model_data <- model_data %>%
  mutate(
    hs4 = sprintf("%04d", as.numeric(hs4))
  )

# Remove gravity year column since it is no longer needed

model_data <- model_data %>%
  select(-year)


# Save merged trade + gravity dataset

fwrite(
  model_data,
  "Data/Processed/model_data_clean.csv"
)


# =====================================================
# ADD ALBERTA SPECIALIZATION DATA
# =====================================================

alberta_spec <- fread(
  "Data/Raw/alberta_specialization.csv"
)


# Standardize HS4 codes for joining

alberta_spec <- alberta_spec %>%
  mutate(
    hs4 = sprintf("%04d", as.numeric(hs4))
  )

# Convert Alberta export values from text
# to numeric values
alberta_spec <- alberta_spec %>%
  mutate(
    alberta_export_value =
      as.numeric(
        gsub(",", "", alberta_export_value)
      )
  )

# Create logged Alberta export values
# Useful for reducing skewness

alberta_spec <- alberta_spec %>%
  mutate(
    log_ab_exports =
      log1p(alberta_export_value)
  )


# Merge Alberta specialization information
# onto the trade dataset

model_data <- model_data %>%
  left_join(
    alberta_spec,
    by = "hs4"
  )

# Create Alberta product indicator:
# 1 = product is currently exported by Alberta
# 0 = product not exported by Alberta
model_data <- model_data %>%
  mutate(
    alberta_product =
      ifelse(
        is.na(alberta_export_value),
        0,
        1
      )
  )

# Check distribution of Alberta/non-Alberta products

table(model_data$alberta_product)


# Keep only products that Alberta already exports.
# This ensures predictions focus on realistic
# Alberta export opportunities.
model_data_ab <- model_data %>%
  filter(alberta_product == 1)

# =====================================================
# FEATURE ENGINEERING
# =====================================================

# Log-transform variables to reduce skewness
# and better match gravity-model assumptions.

model_data_ab <- model_data_ab %>%
  mutate(
    log_trade_value = log1p(trade_value),
    
    log_gdp_o = log1p(gdp_o),
    log_gdp_d = log1p(gdp_d),
    
    log_pop_o = log1p(pop_o),
    log_pop_d = log1p(pop_d),
    
    log_dist = log1p(dist)
  )
summary(model_data_ab$log_trade_value)

# -----------------------------
# Save final modelling dataset
# -----------------------------

fwrite(
  model_data_ab,
  "Data/Processed/model_data_alberta.csv"
)


# =====================================================
# QUALITY CHECKS
# =====================================================


dim(model_data_ab)

table(model_data_ab$exporter)

length(unique(model_data_ab$importer))


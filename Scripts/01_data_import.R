# =====================================================
# Alberta Export Diversification Project
# 01_data_import.R

# =====================================================

library(data.table)
library(dplyr)
library(stringr)

#-------------------------------------------------------
# BACI Country Codes
#-------------------------------------------------------
 
country_codes <- fread(
  "Data/Raw/BACI_HS22_V202601/country_codes_V202601.csv"
)

head(country_codes)

#-------------------------------------------------------
# Product Codes
#-------------------------------------------------------

product_codes <- fread(
  "Data/Raw/BACI_HS22_V202601/product_codes_HS22_V202601.csv"
)

head(product_codes)

#-------------------------------------------------------
# World Bank
#-------------------------------------------------------

worldbank <- fread(
  "Data/Raw/World_Development_Indicators/worldbank.csv"
)

head(worldbank)

#-------------------------------------------------------
# Gravity
#-------------------------------------------------------

gravity <- fread(
  "Data/Raw/Gravity_csv_V202211/Gravity_V202211.csv",
  nrows = 100
)

names(gravity)

# =====================================================
# Alberta Export Diversification Project
# Prepare BACI Data
# =====================================================

library(data.table)
library(dplyr)

#--------------------------------------------------
# Load BACI Country Codes
#--------------------------------------------------

country_codes <- fread(
  "Data/Raw/BACI_HS22_V202601/country_codes_V202601.csv"
)

#--------------------------------------------------
# Load Product Codes
#--------------------------------------------------
 
product_codes <- fread(
  "Data/Raw/BACI_HS22_V202601/product_codes_HS22_V202601.csv"
)

#--------------------------------------------------
# Load only first 10 rows of BACI
#--------------------------------------------------

baci_sample <- fread(
  "Data/Raw/BACI_HS22_V202601/BACI_HS22_Y2024_V202601.csv",
  nrows = 10
)

head(baci_sample)

names(baci_sample)

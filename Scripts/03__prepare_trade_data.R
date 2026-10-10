# =====================================================
# 03_prepare_trade_data.R
# =====================================================

library(data.table)
library(dplyr)

#--------------------------------------------------
# Load Country Codes
#--------------------------------------------------

country_codes <- fread(
  "Data/Raw/BACI_HS22_V202601/country_codes_V202601.csv"
)
 
#--------------------------------------------------
# Load BACI
#--------------------------------------------------

baci <- fread(
  "Data/Raw/BACI_HS22_V202601/BACI_HS22_Y2024_V202601.csv",
  select = c("i","j","k","v")
)

dim(baci)

country_lookup <- country_codes %>%
  select(
    country_code,
    country_iso3
  )


# exporter

baci <- baci %>%
  left_join(
    country_lookup,
    by = c("i" = "country_code")
  )

names(baci)[names(baci)=="country_iso3"] <- "exporter"

# importer

baci <- baci %>%
  left_join(
    country_lookup,
    by = c("j" = "country_code")
  )

names(baci)[names(baci)=="country_iso3"] <- "importer"
countries <- c(
  "CAN",
  "USA",
  "MEX",
  "CHN",
  "JPN",
  "KOR",
  "GBR"
)
baci <- baci %>%
  filter(
    exporter %in% countries
  )


baci <- baci %>%
  mutate(
    hs4 = substr(
      sprintf("%06d", k),
      1,
      4
    )
  )
trade_hs4 <- baci %>%
  group_by(
    exporter,
    importer,
    hs4
  ) %>%
  summarise(
    trade_value = sum(v),
    .groups = "drop"
  )
dim(trade_hs4)

head(trade_hs4)

dir.create("Data/Processed", showWarnings = FALSE)
fwrite(
  trade_hs4,
  "Data/Processed/trade_hs4.csv"
)



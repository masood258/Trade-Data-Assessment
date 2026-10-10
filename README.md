# Question 1 – Alberta Export Growth and Diversification Analysis
## Project Overview

This project assesses Alberta's merchandise export performance and future export diversification opportunities using a combination of international trade data, gravity-model variables, and machine learning techniques.

The analysis was completed as part of an export growth and diversification assessment. The project combines observed 2025 Alberta export data with a predictive model trained on 2024 bilateral international trade flows.

---

## Objectives

The project addresses two questions:

### Part 1 – Alberta's Current Export Profile

- Identify Alberta's top ten export destination countries in 2025.
- Identify the top five HS4 products exported to each destination.

### Part 2 – Alberta's Future Export Opportunities

- Develop a machine-learning model using international merchandise trade data.
- Estimate export opportunity rankings for Alberta.
- Identify the most promising export destinations and products for future growth and diversification.

---

## Data Sources

### Trade Data Online (Government of Canada)

Used to obtain:

- Alberta domestic exports (2024 and 2025)
- Top destination markets
- Top HS4 products by destination
- Alberta HS4 export specialization profile

Website: [Trade Data Online](https://ised-isde.canada.ca/site/ised/en/canadian-importers-database/trade-data-online)---

### CEPII BACI Trade Database

Used for:

- 2024 bilateral merchandise trade flows
- HS4 product-level trade values

https://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=37

---

### CEPII Gravity Database

Used for:

- Distance
- Shared border
- Common official language
- GDP
- Population
- Trade agreement indicators

https://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=8

---

### World Bank Data

Used to support economic and demographic variables.

https://data.worldbank.org

---

## Methodology

### Data Preparation

1. Imported BACI bilateral trade flows.
2. Converted HS6 product codes to HS4.
3. Restricted exporters to:
   - Canada
   - United States
   - Mexico
   - China
   - Japan
   - South Korea
   - United Kingdom
4. Merged gravity-model variables.
5. Constructed an Alberta specialization profile using Alberta's top 25 HS4 exports in 2024.

### Feature Engineering

The model uses:

- HS4 product code
- Exporter GDP
- Importer GDP
- Exporter population
- Importer population
- Bilateral distance
- Shared border
- Common language
- Free-trade agreement indicator
- Alberta export specialization

### Machine Learning Models

Two predictive models were evaluated:

#### Random Forest

Performance:

| Metric | Value |
|----------|--------|
| RMSE | 2.396 |
| MAE | 1.904 |
| R² | 0.588 |

#### XGBoost

Performance:

| Metric | Value |
|----------|--------|
| RMSE | 2.219 |
| MAE | 1.709 |
| R² | 0.627 |

XGBoost achieved the strongest out-of-sample performance and was selected as the final model.

---

## Key Findings

### Alberta's Top Export Destinations (2025)

1. United States
2. China
3. Japan
4. Hong Kong
5. South Korea
6. Singapore
7. Mexico
8. Netherlands
9. Peru
10. Indonesia

The United States accounted for approximately 85% of Alberta's domestic merchandise exports.

---

### Most Important Predictors

According to the XGBoost model:

| Feature | Gain |
|----------|--------|
| Alberta specialization | 19.90% |
| Importer GDP | 19.62% |
| HS4 product | 18.15% |
| Distance | 11.85% |
| Exporter GDP | 11.00% |

The model suggests that:

- Alberta's existing strengths matter.
- Large destination markets matter.
- Product characteristics matter.
- Distance remains an important determinant of trade.

---

### Predicted Export Opportunity Ranking

1. United States
2. China
3. Mexico
4. Japan
5. United Kingdom
6. South Korea
7. Netherlands
8. India
9. Singapore
10. Peru

These destinations represent the strongest relative export opportunities based on the model.

---

## Repository Structure

```text
├── Data
├── Scripts
│   ├── 01_data_import.R
│   ├── 02_prepare_baci.R
│   ├── 03_prepare_trade_data.R
│   ├── 04_merge_gravity_Alberta_build_model_dataset.R
│   ├── 05_random_forest_model.R
│   ├── 06_xgboost_model.R
│   └── 07_alberta_predictions.R
│
├── Figures
│
├── Output
│
│
└── README.md
```

---

## Limitations

- Alberta does not appear directly in international trade databases such as BACI.
- Alberta was represented using provincial GDP, population, and export specialization.
- Opportunity scores represent relative export potential and should not be interpreted as direct forecasts of future export values.
- Gravity variables are derived from the most recent available CEPII release and do not always align perfectly with 2024 economic conditions.

---

## Reproducibility

All analysis was completed in R using:

- data.table
- dplyr
- caret
- randomForest
- xgboost
- tidyr

Scripts are organized sequentially to allow full reproduction of the analytical workflow.

---

---

# Question 2 – Canada's Exposure to U.S. Section 338 Tariffs

## Overview

This analysis estimates Canada's export exposure to U.S. Section 338 tariffs using 2025 Canadian export data and the consolidated U.S. Section 338 product list.

## Methodology

- Converted 554 covered U.S. HTS8 tariff lines to 373 unique HS6 codes.
- Matched Canadian exports to covered HS6 products.
- Calculated exposure values and exposure intensity by province and product group.
- Identified Alberta's major exposed HS4 products and compared Alberta with other major exporting provinces.

## Key Findings

- Canada's estimated exposure is **$36.58 billion** (6.5% of exports to the U.S.).
- Ontario and Quebec account for approximately **72%** of total exposure.
- Alberta exposure is **$1.58 billion** with an exposure intensity of **1.0%**.
- Alberta's most exposed HS4 groups are:
  - HS4 8414 – Pumps, compressors and fans
  - HS4 8537 – Electrical control equipment
  - HS4 3824 – Specialty chemical preparations

## Deliverables

```text
Question2_Section338/
├── Canada_Section_338_Exposure.xlsx
├── Canada_Section_338_Exposure_Report.docx
└── Canada_Section_338_Exposure_Report.pdf
```

## Author

Masood Abdinejad

Senior Data Analyst

Edmonton, Alberta



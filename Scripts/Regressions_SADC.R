# 03_regressions.R (Updated to Mismatch = 4)


# ============================================================
# 03_regressions.R
# Project: Public Service Visibility Paradox
# Purpose: Estimate regression models following H1–H8 sequence.
#
# Key definitions:
# H1/H8 shortage-reduction models:
# Severe shortage = Q6 == 4 for final consistency with presented results.
#
# H2–H7 mismatch-cascade models:
# Severe mismatch = service visible + Q6 == 4.
# ============================================================


# -----------------------------
# 1. Packages
# -----------------------------


packages_needed <- c(
  "dplyr",
  "readr",
  "haven",
  "broom",
  "tidyr",
  "stargazer"
)


packages_to_install <- packages_needed[
  !(packages_needed %in% installed.packages()[, "Package"])
]


if (length(packages_to_install) > 0) {
  install.packages(packages_to_install)
}


library(dplyr)
library(readr)
library(haven)
library(broom)
library(tidyr)
library(stargazer)


# -----------------------------
# 2. Folders
# -----------------------------


dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)


# -----------------------------
# 3. Load data
# -----------------------------


if (file.exists("data/cleaned/sadc_analysis.rds")) {
  sadc_analysis <- readRDS("data/cleaned/sadc_analysis.rds")
} else if (file.exists("data/cleaned/sadc_analysis.csv")) {
  sadc_analysis <- read_csv("data/cleaned/sadc_analysis.csv", show_col_types = FALSE)
} else if (file.exists("sadc_final_analysis_dataset.csv")) {
  sadc_analysis <- read_csv("sadc_final_analysis_dataset.csv", show_col_types = FALSE)
} else {
  stop("Dataset not found. Run 01_data_cleaning.R first.")
}


# -----------------------------
# 4. Standardize variables
# -----------------------------


clean_ab <- function(x) {
  x <- as.numeric(zap_labels(x))
  x <- ifelse(x %in% c(-1, 8, 9), NA, x)
  return(x)
}


sig_star <- function(p) {
  case_when(
    p < 0.001 ~ "***",
    p < 0.01 ~ "**",
    p < 0.05 ~ "*",
    p < 0.1 ~ ".",
    TRUE ~ ""
  )
}


extract_key <- function(model, term_name, model_name) {
  tidy(model) %>%
    filter(term == term_name) %>%
    mutate(
      model = model_name,
      coefficient = round(estimate, 3),
      odds_ratio = round(exp(estimate), 3),
      p_value = signif(p.value, 3),
      stars = sig_star(p.value),
      result = paste0(coefficient, stars)
    ) %>%
    select(model, term, result, odds_ratio, p_value)
}


sadc_regression <- sadc_analysis %>%
  mutate(
    EA_FAC_F = clean_ab(EA_FAC_F),
    Q6E = clean_ab(Q6E),
    
    
    EA_FAC_D = clean_ab(EA_FAC_D),
    Q6C = clean_ab(Q6C),
    
    
    EA_SVC_B = clean_ab(EA_SVC_B),
    Q6B = clean_ab(Q6B),
    
    
    EA_SVC_A = clean_ab(EA_SVC_A),
    Q6D = clean_ab(Q6D),
    
    
    URBRUR = clean_ab(URBRUR),
    COUNTRY = clean_ab(COUNTRY),
    
    
    country_name = as.character(country_name),
    
    
    location_type = case_when(
      URBRUR == 1 ~ "Urban",
      URBRUR == 2 ~ "Rural",
      URBRUR == 3 ~ "Peri-urban",
      TRUE ~ as.character(location_type)
    ),
    
    
    # Service presence
    money_services_present = ifelse(EA_FAC_F == 1, 1, ifelse(EA_FAC_F %in% c(0, 2), 0, NA)),
    health_clinic_present = ifelse(EA_FAC_D == 1, 1, ifelse(EA_FAC_D %in% c(0, 2), 0, NA)),
    piped_water_present = ifelse(EA_SVC_B == 1, 1, ifelse(EA_SVC_B %in% c(0, 2), 0, NA)),
    electricity_grid_present = ifelse(EA_SVC_A == 1, 1, ifelse(EA_SVC_A %in% c(0, 2), 0, NA)),
    
    
    # Severe shortages for final consistency: Q6 == 4
    severe_cash_shortage = ifelse(Q6E == 4, 1, ifelse(Q6E < 4, 0, NA)),
    severe_medical_shortage = ifelse(Q6C == 4, 1, ifelse(Q6C < 4, 0, NA)),
    severe_water_shortage = ifelse(Q6B == 4, 1, ifelse(Q6B < 4, 0, NA)),
    severe_fuel_shortage = ifelse(Q6D == 4, 1, ifelse(Q6D < 4, 0, NA)),
    
    
    # H2-H7 severe mismatch variables
    cash_access_mismatch = case_when(
      EA_FAC_F == 1 & Q6E == 4 ~ 1,
      EA_FAC_F == 1 & Q6E < 4 ~ 0,
      TRUE ~ NA_real_
    ),
    
    
    health_mismatch = case_when(
      EA_FAC_D == 1 & Q6C == 4 ~ 1,
      EA_FAC_D == 1 & Q6C < 4 ~ 0,
      TRUE ~ NA_real_
    ),
    
    
    water_mismatch = case_when(
      EA_SVC_B == 1 & Q6B == 4 ~ 1,
      EA_SVC_B == 1 & Q6B < 4 ~ 0,
      TRUE ~ NA_real_
    ),
    
    
    electricity_fuel_mismatch = case_when(
      EA_SVC_A == 1 & Q6D == 4 ~ 1,
      EA_SVC_A == 1 & Q6D < 4 ~ 0,
      TRUE ~ NA_real_
    ),
    
    
    severe_shortage_count =
      severe_water_shortage +
      severe_medical_shortage +
      severe_fuel_shortage +
      severe_cash_shortage,
    
    
    any_severe_shortage = ifelse(severe_shortage_count >= 1, 1, 0)
  )


write_csv(sadc_regression, "data/cleaned/sadc_regression_dataset.csv")


# ============================================================
# H1: SERVICE VISIBILITY HYPOTHESIS
# ============================================================


reg_data <- sadc_regression %>%
  filter(
    !is.na(piped_water_present),
    !is.na(health_clinic_present),
    !is.na(electricity_grid_present),
    !is.na(money_services_present),
    !is.na(severe_water_shortage),
    !is.na(severe_medical_shortage),
    !is.na(severe_fuel_shortage),
    !is.na(severe_cash_shortage),
    !is.na(location_type),
    !is.na(country_name)
  )


model_water_basic <- glm(
  severe_water_shortage ~ piped_water_present + health_clinic_present +
    electricity_grid_present + money_services_present +
    location_type + country_name,
  data = reg_data,
  family = binomial
)


model_health_basic <- glm(
  severe_medical_shortage ~ piped_water_present + health_clinic_present +
    electricity_grid_present + money_services_present +
    location_type + country_name,
  data = reg_data,
  family = binomial
)


model_fuel_basic <- glm(
  severe_fuel_shortage ~ piped_water_present + health_clinic_present +
    electricity_grid_present + money_services_present +
    location_type + country_name,
  data = reg_data,
  family = binomial
)


model_cash_basic <- glm(
  severe_cash_shortage ~ piped_water_present + health_clinic_present +
    electricity_grid_present + money_services_present +
    location_type + country_name,
  data = reg_data,
  family = binomial
)


service_presence_results <- bind_rows(
  tidy(model_water_basic) %>% mutate(model = "Severe water shortage"),
  tidy(model_health_basic) %>% mutate(model = "Severe medical-care shortage"),
  tidy(model_fuel_basic) %>% mutate(model = "Severe cooking-fuel shortage"),
  tidy(model_cash_basic) %>% mutate(model = "Severe cash-income shortage")
) %>%
  filter(term %in% c(
    "piped_water_present",
    "health_clinic_present",
    "electricity_grid_present",
    "money_services_present"
  )) %>%
  mutate(
    coefficient = round(estimate, 3),
    odds_ratio = round(exp(estimate), 3),
    p_value = signif(p.value, 3),
    stars = sig_star(p.value),
    result = paste0(coefficient, stars)
  ) %>%
  select(model, term, result, odds_ratio, p_value)


write_csv(service_presence_results, "results/tables/H1_service_visibility_results.csv")


# ============================================================
# H2: SERVICE MISMATCH HYPOTHESIS
# ============================================================


mismatch_rates <- tibble(
  service = c("Cash Access", "Health Clinic", "Water", "Electricity/Fuel"),
  mismatch_rate = c(
    mean(sadc_regression$cash_access_mismatch, na.rm = TRUE),
    mean(sadc_regression$health_mismatch, na.rm = TRUE),
    mean(sadc_regression$water_mismatch, na.rm = TRUE),
    mean(sadc_regression$electricity_fuel_mismatch, na.rm = TRUE)
  )
) %>%
  mutate(mismatch_rate_percent = round(mismatch_rate * 100, 1)) %>%
  arrange(desc(mismatch_rate_percent))


write_csv(mismatch_rates, "results/tables/H2_service_mismatch_rates.csv")


# ============================================================
# H3: CASH BOTTLENECK HYPOTHESIS
# ============================================================


model_cash_to_health <- glm(
  health_mismatch ~ cash_access_mismatch,
  data = sadc_regression,
  family = binomial
)


model_cash_to_water <- glm(
  water_mismatch ~ cash_access_mismatch,
  data = sadc_regression,
  family = binomial
)


model_cash_to_power <- glm(
  electricity_fuel_mismatch ~ cash_access_mismatch,
  data = sadc_regression,
  family = binomial
)


cash_bottleneck_results <- bind_rows(
  extract_key(model_cash_to_health, "cash_access_mismatch", "Cash -> Health"),
  extract_key(model_cash_to_water, "cash_access_mismatch", "Cash -> Water"),
  extract_key(model_cash_to_power, "cash_access_mismatch", "Cash -> Electricity/Fuel")
)


write_csv(cash_bottleneck_results, "results/tables/H3_cash_bottleneck_results.csv")


# ============================================================
# H4: HEALTH TRANSMISSION HYPOTHESIS
# ============================================================


model_health_to_cash <- glm(
  cash_access_mismatch ~ health_mismatch,
  data = sadc_regression,
  family = binomial
)


model_health_to_water <- glm(
  water_mismatch ~ health_mismatch,
  data = sadc_regression,
  family = binomial
)


model_health_to_power <- glm(
  electricity_fuel_mismatch ~ health_mismatch,
  data = sadc_regression,
  family = binomial
)


health_transmission_results <- bind_rows(
  extract_key(model_health_to_cash, "health_mismatch", "Health -> Cash"),
  extract_key(model_health_to_water, "health_mismatch", "Health -> Water"),
  extract_key(model_health_to_power, "health_mismatch", "Health -> Electricity/Fuel")
)


write_csv(health_transmission_results, "results/tables/H4_health_transmission_results.csv")


# ============================================================
# H5: DOUBLE WHAMMY HYPOTHESIS
# ============================================================


model_double_water <- glm(
  water_mismatch ~ cash_access_mismatch + health_mismatch,
  data = sadc_regression,
  family = binomial
)


model_double_power <- glm(
  electricity_fuel_mismatch ~ cash_access_mismatch + health_mismatch,
  data = sadc_regression,
  family = binomial
)


double_whammy_results <- bind_rows(
  extract_key(model_double_water, "cash_access_mismatch", "Cash + Health -> Water"),
  extract_key(model_double_water, "health_mismatch", "Cash + Health -> Water"),
  extract_key(model_double_power, "cash_access_mismatch", "Cash + Health -> Electricity/Fuel"),
  extract_key(model_double_power, "health_mismatch", "Cash + Health -> Electricity/Fuel")
)


write_csv(double_whammy_results, "results/tables/H5_double_whammy_results.csv")


# ============================================================
# H6: URBAN TRAP HYPOTHESIS
# ============================================================


urban_data <- sadc_regression %>% filter(URBRUR == 1)
rural_data <- sadc_regression %>% filter(URBRUR == 2)


model_urban_cash_to_health <- glm(
  health_mismatch ~ cash_access_mismatch,
  data = urban_data,
  family = binomial
)


model_rural_cash_to_health <- glm(
  health_mismatch ~ cash_access_mismatch,
  data = rural_data,
  family = binomial
)


model_urban_cash_to_water <- glm(
  water_mismatch ~ cash_access_mismatch,
  data = urban_data,
  family = binomial
)


model_rural_cash_to_water <- glm(
  water_mismatch ~ cash_access_mismatch,
  data = rural_data,
  family = binomial
)


model_urban_cash_to_power <- glm(
  electricity_fuel_mismatch ~ cash_access_mismatch,
  data = urban_data,
  family = binomial
)


model_rural_cash_to_power <- glm(
  electricity_fuel_mismatch ~ cash_access_mismatch,
  data = rural_data,
  family = binomial
)


urban_trap_results <- bind_rows(
  extract_key(model_urban_cash_to_health, "cash_access_mismatch", "Urban Cash -> Health"),
  extract_key(model_rural_cash_to_health, "cash_access_mismatch", "Rural Cash -> Health"),
  extract_key(model_urban_cash_to_water, "cash_access_mismatch", "Urban Cash -> Water"),
  extract_key(model_rural_cash_to_water, "cash_access_mismatch", "Rural Cash -> Water"),
  extract_key(model_urban_cash_to_power, "cash_access_mismatch", "Urban Cash -> Electricity/Fuel"),
  extract_key(model_rural_cash_to_power, "cash_access_mismatch", "Rural Cash -> Electricity/Fuel")
)


write_csv(urban_trap_results, "results/tables/H6_urban_trap_results.csv")


# ============================================================
# H7: GOVERNANCE FRONTIER HYPOTHESIS
# ============================================================


mauritius_data <- sadc_regression %>% filter(COUNTRY == 23)
zimbabwe_data <- sadc_regression %>% filter(COUNTRY == 40)


model_mauritius_cash_to_health <- glm(
  health_mismatch ~ cash_access_mismatch,
  data = mauritius_data,
  family = binomial
)


model_zimbabwe_cash_to_health <- glm(
  health_mismatch ~ cash_access_mismatch,
  data = zimbabwe_data,
  family = binomial
)


model_mauritius_cash_to_water <- glm(
  water_mismatch ~ cash_access_mismatch,
  data = mauritius_data,
  family = binomial
)


model_zimbabwe_cash_to_water <- glm(
  water_mismatch ~ cash_access_mismatch,
  data = zimbabwe_data,
  family = binomial
)


model_mauritius_cash_to_power <- glm(
  electricity_fuel_mismatch ~ cash_access_mismatch,
  data = mauritius_data,
  family = binomial
)


model_zimbabwe_cash_to_power <- glm(
  electricity_fuel_mismatch ~ cash_access_mismatch,
  data = zimbabwe_data,
  family = binomial
)


governance_frontier_results <- bind_rows(
  extract_key(model_mauritius_cash_to_health, "cash_access_mismatch", "Mauritius Cash -> Health"),
  extract_key(model_zimbabwe_cash_to_health, "cash_access_mismatch", "Zimbabwe Cash -> Health"),
  extract_key(model_mauritius_cash_to_water, "cash_access_mismatch", "Mauritius Cash -> Water"),
  extract_key(model_zimbabwe_cash_to_water, "cash_access_mismatch", "Zimbabwe Cash -> Water"),
  extract_key(model_mauritius_cash_to_power, "cash_access_mismatch", "Mauritius Cash -> Electricity/Fuel"),
  extract_key(model_zimbabwe_cash_to_power, "cash_access_mismatch", "Zimbabwe Cash -> Electricity/Fuel")
)


write_csv(governance_frontier_results, "results/tables/H7_governance_frontier_results.csv")


# ============================================================
# H8: SERVICE SYNERGY AND PRIORITY HYPOTHESIS
# ============================================================


model_four_way <- glm(
  any_severe_shortage ~
    piped_water_present *
    health_clinic_present *
    electricity_grid_present *
    money_services_present +
    location_type +
    country_name,
  data = reg_data,
  family = binomial
)


four_way_results <- tidy(model_four_way) %>%
  filter(grepl(
    "piped_water_present:health_clinic_present:electricity_grid_present:money_services_present",
    term
  )) %>%
  mutate(
    coefficient = round(estimate, 3),
    p_value = signif(p.value, 3),
    stars = sig_star(p.value),
    result = paste0(coefficient, stars)
  ) %>%
  select(term, result, p_value)


model_shortage_count_poisson <- glm(
  severe_shortage_count ~
    piped_water_present +
    health_clinic_present +
    electricity_grid_present +
    money_services_present +
    location_type +
    country_name,
  data = reg_data,
  family = poisson
)


poisson_priority_results <- tidy(model_shortage_count_poisson) %>%
  filter(term %in% c(
    "piped_water_present",
    "health_clinic_present",
    "electricity_grid_present",
    "money_services_present"
  )) %>%
  mutate(
    incidence_rate_ratio = round(exp(estimate), 3),
    p_value = signif(p.value, 3),
    stars = sig_star(p.value)
  ) %>%
  select(term, incidence_rate_ratio, p_value, stars)


write_csv(four_way_results, "results/tables/H8_four_way_service_synergy_results.csv")
write_csv(poisson_priority_results, "results/tables/H8_poisson_priority_results.csv")


# ============================================================
# PRINT RESULTS IN ORDER
# ============================================================


cat("\n============================================================\n")
cat("REGRESSION RESULTS BY HYPOTHESIS\n")
cat("============================================================\n")
cat("Definition used: severe shortage / severe mismatch = Q6 == 4.\n")
cat("Regression sample size:", nrow(reg_data), "\n")


cat("\nH1: SERVICE VISIBILITY HYPOTHESIS\n")
print(service_presence_results)


cat("\nH2: SERVICE MISMATCH HYPOTHESIS\n")
print(mismatch_rates)


cat("\nH3: CASH BOTTLENECK HYPOTHESIS\n")
print(cash_bottleneck_results)


cat("\nH4: HEALTH TRANSMISSION HYPOTHESIS\n")
print(health_transmission_results)


cat("\nH5: DOUBLE WHAMMY HYPOTHESIS\n")
print(double_whammy_results)


cat("\nH6: URBAN TRAP HYPOTHESIS\n")
print(urban_trap_results)


cat("\nH7: GOVERNANCE FRONTIER HYPOTHESIS\n")
print(governance_frontier_results)


cat("\nH8: SERVICE SYNERGY AND PRIORITY HYPOTHESIS\n")
print(four_way_results)
print(poisson_priority_results)


cat("\nAll regression tables saved in results/tables/.\n")
cat("============================================================\n")

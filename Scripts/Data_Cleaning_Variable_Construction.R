# ============================================================
# data_cleaning.R
# ============================================================

# -----------------------------
# 1. Packages
# -----------------------------

packages_needed <- c("dplyr", "readr", "haven", "forcats")

packages_to_install <- packages_needed[
  !(packages_needed %in% installed.packages()[, "Package"])
]

if (length(packages_to_install) > 0) {
  install.packages(packages_to_install)
}

library(dplyr)
library(readr)
library(haven)
library(forcats)

# -----------------------------
# 2. Create GitHub-style folders
# -----------------------------

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)
dir.create("scripts", recursive = TRUE, showWarnings = FALSE)
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("docs", recursive = TRUE, showWarnings = FALSE)

# -----------------------------
# 3. Load existing final dataset
# -----------------------------

if (file.exists("data/cleaned/sadc_final_analysis_dataset.csv")) {
  sadc_analysis <- read_csv(
    "data/cleaned/sadc_final_analysis_dataset.csv",
    show_col_types = FALSE
  )
} else if (file.exists("sadc_final_analysis_dataset.csv")) {
  file.copy(
    from = "sadc_final_analysis_dataset.csv",
    to = "data/cleaned/sadc_final_analysis_dataset.csv",
    overwrite = TRUE
  )
  
  sadc_analysis <- read_csv(
    "data/cleaned/sadc_final_analysis_dataset.csv",
    show_col_types = FALSE
  )
} else {
  stop(
    "sadc_final_analysis_dataset.csv not found. Put it in the main project folder or in data/cleaned/."
  )
}

# -----------------------------
# 4. Helper function
# -----------------------------

get_existing_var <- function(data, possible_names) {
  existing <- possible_names[possible_names %in% names(data)]
  
  if (length(existing) == 0) {
    return(rep(NA, nrow(data)))
  }
  
  data[[existing[1]]]
}

# -----------------------------
# 5. Create standardized raw inputs if needed
# -----------------------------

sadc_analysis <- sadc_analysis %>%
  mutate(
    # Country
    country_name = if ("country_name" %in% names(.)) {
      as.character(country_name)
    } else {
      as.character(get_existing_var(., c("COUNTRY", "country", "Country")))
    },
    
    # Location
    location_type = if ("location_type" %in% names(.)) {
      as.character(location_type)
    } else {
      as.character(get_existing_var(., c("URBRUR", "urban_rural", "location", "Location")))
    },
    
    # Shortage raw variables
    q6b_num = as.numeric(get_existing_var(., c("q6b_num", "Q6B", "water_shortage"))),
    q6c_num = as.numeric(get_existing_var(., c("q6c_num", "Q6C", "medical_shortage"))),
    q6d_num = as.numeric(get_existing_var(., c("q6d_num", "Q6D", "fuel_shortage"))),
    q6e_num = as.numeric(get_existing_var(., c("q6e_num", "Q6E", "cash_shortage"))),
    
    # Service presence variables
    piped_water_present = as.numeric(get_existing_var(
      .,
      c("piped_water_present", "EA_SVC_B", "ea_svc_b_num")
    )),
    
    health_clinic_present = as.numeric(get_existing_var(
      .,
      c("health_clinic_present", "EA_FAC_D", "ea_fac_d_num")
    )),
    
    electricity_grid_present = as.numeric(get_existing_var(
      .,
      c("electricity_grid_present", "EA_SVC_A", "ea_svc_a_num")
    )),
    
    money_services_present = as.numeric(get_existing_var(
      .,
      c("money_services_present", "EA_FAC_F", "ea_fac_f_num")
    ))
  )

# -----------------------------
# 6. Standardize service presence values
# -----------------------------
# This assumes 1 = present. Values 0 or 2 are treated as absent.

sadc_analysis <- sadc_analysis %>%
  mutate(
    piped_water_present = case_when(
      piped_water_present == 1 ~ 1,
      piped_water_present %in% c(0, 2) ~ 0,
      TRUE ~ NA_real_
    ),
    
    health_clinic_present = case_when(
      health_clinic_present == 1 ~ 1,
      health_clinic_present %in% c(0, 2) ~ 0,
      TRUE ~ NA_real_
    ),
    
    electricity_grid_present = case_when(
      electricity_grid_present == 1 ~ 1,
      electricity_grid_present %in% c(0, 2) ~ 0,
      TRUE ~ NA_real_
    ),
    
    money_services_present = case_when(
      money_services_present == 1 ~ 1,
      money_services_present %in% c(0, 2) ~ 0,
      TRUE ~ NA_real_
    )
  )

# -----------------------------
# 7. Create severe shortage variables
# -----------------------------
# Severe shortage definition:
# Q6 values 2-4 = severe shortage
# Q6 values 0-1 = no severe shortage

sadc_analysis <- sadc_analysis %>%
  mutate(
    severe_water_shortage = case_when(
      q6b_num %in% c(2, 3, 4) ~ 1,
      q6b_num %in% c(0, 1) ~ 0,
      TRUE ~ NA_real_
    ),
    
    severe_medical_shortage = case_when(
      q6c_num %in% c(2, 3, 4) ~ 1,
      q6c_num %in% c(0, 1) ~ 0,
      TRUE ~ NA_real_
    ),
    
    severe_fuel_shortage = case_when(
      q6d_num %in% c(2, 3, 4) ~ 1,
      q6d_num %in% c(0, 1) ~ 0,
      TRUE ~ NA_real_
    ),
    
    severe_cash_shortage = case_when(
      q6e_num %in% c(2, 3, 4) ~ 1,
      q6e_num %in% c(0, 1) ~ 0,
      TRUE ~ NA_real_
    )
  )

# -----------------------------
# 8. Create mismatch variables if needed
# -----------------------------
# Severe mismatch definition:
# service present + Q6 value 4 = mismatch
# service present + Q6 below 4 = no mismatch
# service absent = NA

sadc_analysis <- sadc_analysis %>%
  mutate(
    water_mismatch = if ("water_mismatch" %in% names(.)) {
      as.numeric(water_mismatch)
    } else {
      case_when(
        piped_water_present == 1 & q6b_num == 4 ~ 1,
        piped_water_present == 1 & q6b_num < 4 ~ 0,
        TRUE ~ NA_real_
      )
    },
    
    health_mismatch = if ("health_mismatch" %in% names(.)) {
      as.numeric(health_mismatch)
    } else {
      case_when(
        health_clinic_present == 1 & q6c_num == 4 ~ 1,
        health_clinic_present == 1 & q6c_num < 4 ~ 0,
        TRUE ~ NA_real_
      )
    },
    
    electricity_fuel_mismatch = if ("electricity_fuel_mismatch" %in% names(.)) {
      as.numeric(electricity_fuel_mismatch)
    } else {
      case_when(
        electricity_grid_present == 1 & q6d_num == 4 ~ 1,
        electricity_grid_present == 1 & q6d_num < 4 ~ 0,
        TRUE ~ NA_real_
      )
    },
    
    cash_access_mismatch = if ("cash_access_mismatch" %in% names(.)) {
      as.numeric(cash_access_mismatch)
    } else {
      case_when(
        money_services_present == 1 & q6e_num == 4 ~ 1,
        money_services_present == 1 & q6e_num < 4 ~ 0,
        TRUE ~ NA_real_
      )
    }
  )

# -----------------------------
# 9. Additional analysis variables
# -----------------------------

sadc_analysis <- sadc_analysis %>%
  mutate(
    severe_shortage_count =
      severe_water_shortage +
      severe_medical_shortage +
      severe_fuel_shortage +
      severe_cash_shortage,
    
    any_severe_shortage = ifelse(severe_shortage_count >= 1, 1, 0)
  )

# -----------------------------
# 10. Final checks
# -----------------------------

required_variables <- c(
  "country_name",
  "location_type",
  "piped_water_present",
  "health_clinic_present",
  "electricity_grid_present",
  "money_services_present",
  "severe_water_shortage",
  "severe_medical_shortage",
  "severe_fuel_shortage",
  "severe_cash_shortage",
  "water_mismatch",
  "health_mismatch",
  "electricity_fuel_mismatch",
  "cash_access_mismatch",
  "severe_shortage_count",
  "any_severe_shortage"
)

missing_variables <- setdiff(required_variables, names(sadc_analysis))

if (length(missing_variables) > 0) {
  stop(
    paste(
      "The following required variables are still missing:",
      paste(missing_variables, collapse = ", ")
    )
  )
}

# -----------------------------
# 11. Save cleaned analysis data
# -----------------------------

write_csv(
  sadc_analysis,
  "data/cleaned/sadc_analysis.csv"
)

saveRDS(
  sadc_analysis,
  "data/cleaned/sadc_analysis.rds"
)

# -----------------------------
# 12. Quick checks
# -----------------------------

cat("\nCleaned dataset saved successfully.\n")
cat("Rows:", nrow(sadc_analysis), "\n")
cat("Columns:", ncol(sadc_analysis), "\n\n")

cat("Countries included:\n")
print(sort(unique(sadc_analysis$country_name)))

cat("\nLocation types:\n")
print(table(sadc_analysis$location_type, useNA = "ifany"))

cat("\nSevere shortage means:\n")
print(
  sadc_analysis %>%
    summarise(
      severe_water_shortage = mean(severe_water_shortage, na.rm = TRUE),
      severe_medical_shortage = mean(severe_medical_shortage, na.rm = TRUE),
      severe_fuel_shortage = mean(severe_fuel_shortage, na.rm = TRUE),
      severe_cash_shortage = mean(severe_cash_shortage, na.rm = TRUE)
    )
)

cat("\nMismatch means:\n")
print(
  sadc_analysis %>%
    summarise(
      water_mismatch = mean(water_mismatch, na.rm = TRUE),
      health_mismatch = mean(health_mismatch, na.rm = TRUE),
      electricity_fuel_mismatch = mean(electricity_fuel_mismatch, na.rm = TRUE),
      cash_access_mismatch = mean(cash_access_mismatch, na.rm = TRUE)
    )
)

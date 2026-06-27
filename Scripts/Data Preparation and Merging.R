############################################################
#01_data loading and merging
# Project: Public Service Visibility Paradox

# Purpose: Data Preparation and merging

############################################################

# ==========================================================

# Load Packages

# ==========================================================

library(tidyverse)
library(haven)
library(dplyr)
library(purrr)
# ============================================================

# List all .sav files
all_sav_files <- list.files(
  pattern = "\\.sav$",
  full.names = TRUE
)

length(all_sav_files)

# Project variables only
project_vars <- c(
  "URBRUR",
  "Q6B",
  "Q6C",
  "Q6D",
  "Q6E",
  "EA_SVC_A",
  "EA_SVC_B",
  "EA_FAC_D",
  "EA_FAC_F"
)

# Country lookup based on file names
country_lookup <- data.frame(
  file_pattern = c(
    "ang_r9",
    "BOT_R9",
    "ESW_R9",
    "ken_r9",
    "les_r9",
    "MAD_R9",
    "mlw_r9",
    "MAU_R9",
    "MOZ_R9",
    "nam_r9",
    "SEY_R9",
    "SAF_R9",
    "TAN_R9",
    "UGA_R9",
    "ZAM_R9",
    "zim_r9"
  ),
  COUNTRY = c(2, 4, 10, 16, 17, 19, 20, 23, 25, 26, 31, 33, 35, 38, 39, 40),
  country_name = c(
    "Angola",
    "Botswana",
    "Eswatini",
    "Kenya",
    "Lesotho",
    "Madagascar",
    "Malawi",
    "Mauritius",
    "Mozambique",
    "Namibia",
    "Seychelles",
    "South Africa",
    "Tanzania",
    "Uganda",
    "Zambia",
    "Zimbabwe"
  )
)

# Function to identify country from file name
get_country_info <- function(file_name) {
  matched_row <- country_lookup[
    sapply(country_lookup$file_pattern, function(pattern) grepl(pattern, file_name)),
  ]
  
  if (nrow(matched_row) != 1) {
    stop(paste("Country not matched correctly for file:", file_name))
  }
  
  return(matched_row)
}

# Merge files
sadc_final_analysis_dataset <- map_dfr(all_sav_files, function(file) {
  
  file_base <- basename(file)
  country_info <- get_country_info(file_base)
  
  read_sav(file) %>%
    select(any_of(project_vars)) %>%
    mutate(
      across(
        everything(),
        ~ as.numeric(zap_labels(.))
      )
    ) %>%
    mutate(
      COUNTRY = country_info$COUNTRY,
      country_name = country_info$country_name,
      source_file = file_base
    ) %>%
    select(
      COUNTRY,
      country_name,
      source_file,
      everything()
    )
})

# Check merged data
dim(sadc_final_analysis_dataset)

table(sadc_final_analysis_dataset$country_name)

head(sadc_final_analysis_dataset)

# Save final merged dataset
write.csv(
  sadc_final_analysis_dataset,
  "sadc_final_analysis_dataset.csv",
  row.names = FALSE
)

cat("Merge completed successfully. File saved as sadc_final_analysis_dataset.csv\n")

# ============================================================
# descriptive_analysis.R
# Purpose: Produce descriptive mismatch rates, urban-rural tables,
# country rankings, hotspot tables, and descriptive graphs.
#
# FINAL DEFINITION:
# Severe shortage = Q6 value 4 only
# Mismatch = service present + severe related shortage
# ============================================================

# -----------------------------
# 1. Packages
# -----------------------------

packages_needed <- c(
  "dplyr",
  "readr",
  "tidyr",
  "ggplot2",
  "scales",
  "forcats"
)

packages_to_install <- packages_needed[
  !(packages_needed %in% installed.packages()[, "Package"])
]

if (length(packages_to_install) > 0) {
  install.packages(packages_to_install)
}

library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
library(scales)
library(forcats)

# -----------------------------
# 2. Create output folders
# -----------------------------

dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

# -----------------------------
# 3. Load cleaned data
# -----------------------------

sadc_analysis <- read_csv(
  "sadc_final_analysis_dataset.csv",
  show_col_types = FALSE
)

# -----------------------------
# 4. Rebuild descriptive variables
# -----------------------------

clean_ab <- function(x) {
  x <- as.numeric(x)
  x <- ifelse(x %in% c(-1, 8, 9), NA, x)
  return(x)
}

make_severe_descriptive <- function(x) {
  case_when(
    is.na(x) ~ NA_real_,
    x == 4 ~ 1,
    x %in% c(0, 1, 2, 3) ~ 0,
    TRUE ~ NA_real_
  )
}

recode_service_present <- function(x) {
  x <- as.numeric(x)
  case_when(
    is.na(x) ~ NA_real_,
    x == 1 ~ 1,
    x %in% c(0, 2) ~ 0,
    TRUE ~ NA_real_
  )
}

sadc_analysis <- sadc_analysis %>%
  mutate(
    water_shortage = if ("water_shortage" %in% names(.)) clean_ab(water_shortage) else clean_ab(Q6B),
    medical_shortage = if ("medical_shortage" %in% names(.)) clean_ab(medical_shortage) else clean_ab(Q6C),
    fuel_shortage = if ("fuel_shortage" %in% names(.)) clean_ab(fuel_shortage) else clean_ab(Q6D),
    cash_shortage = if ("cash_shortage" %in% names(.)) clean_ab(cash_shortage) else clean_ab(Q6E),
    
    piped_water_present = if ("piped_water_present" %in% names(.)) {
      recode_service_present(piped_water_present)
    } else {
      recode_service_present(EA_SVC_B)
    },
    
    health_clinic_present = if ("health_clinic_present" %in% names(.)) {
      recode_service_present(health_clinic_present)
    } else {
      recode_service_present(EA_FAC_D)
    },
    
    electricity_grid_present = if ("electricity_grid_present" %in% names(.)) {
      recode_service_present(electricity_grid_present)
    } else {
      recode_service_present(EA_SVC_A)
    },
    
    money_services_present = if ("money_services_present" %in% names(.)) {
      recode_service_present(money_services_present)
    } else {
      recode_service_present(EA_FAC_F)
    },
    
    location_type = case_when(
      URBRUR == 1 ~ "Urban",
      URBRUR == 2 ~ "Rural",
      URBRUR == 3 ~ "Peri-urban",
      TRUE ~ NA_character_
    ),
    
    location_type = factor(
      location_type,
      levels = c("Urban", "Peri-urban", "Rural")
    ),
    
    severe_water_shortage = make_severe_descriptive(water_shortage),
    severe_medical_shortage = make_severe_descriptive(medical_shortage),
    severe_fuel_shortage = make_severe_descriptive(fuel_shortage),
    severe_cash_shortage = make_severe_descriptive(cash_shortage),
    
    water_mismatch = case_when(
      piped_water_present == 1 & severe_water_shortage == 1 ~ 1,
      piped_water_present == 1 & severe_water_shortage == 0 ~ 0,
      TRUE ~ NA_real_
    ),
    
    health_mismatch = case_when(
      health_clinic_present == 1 & severe_medical_shortage == 1 ~ 1,
      health_clinic_present == 1 & severe_medical_shortage == 0 ~ 0,
      TRUE ~ NA_real_
    ),
    
    electricity_fuel_mismatch = case_when(
      electricity_grid_present == 1 & severe_fuel_shortage == 1 ~ 1,
      electricity_grid_present == 1 & severe_fuel_shortage == 0 ~ 0,
      TRUE ~ NA_real_
    ),
    
    cash_access_mismatch = case_when(
      money_services_present == 1 & severe_cash_shortage == 1 ~ 1,
      money_services_present == 1 & severe_cash_shortage == 0 ~ 0,
      TRUE ~ NA_real_
    )
  )

# -----------------------------
# 5. Overall mismatch rates
# -----------------------------

overall_mismatch_rates <- tibble(
  service = c(
    "Water",
    "Health",
    "Electricity/Fuel",
    "Cash Access"
  ),
  mismatch_rate = c(
    mean(sadc_analysis$water_mismatch, na.rm = TRUE),
    mean(sadc_analysis$health_mismatch, na.rm = TRUE),
    mean(sadc_analysis$electricity_fuel_mismatch, na.rm = TRUE),
    mean(sadc_analysis$cash_access_mismatch, na.rm = TRUE)
  )
) %>%
  mutate(
    mismatch_rate_percent = round(mismatch_rate * 100, 1)
  ) %>%
  arrange(desc(mismatch_rate_percent))

write_csv(
  overall_mismatch_rates,
  "results/tables/overall_mismatch_rates.csv"
)

print(overall_mismatch_rates)

# -----------------------------
# 6. Urban-rural mismatch rates
# -----------------------------

urban_rural_mismatch <- sadc_analysis %>%
  filter(!is.na(location_type)) %>%
  group_by(location_type) %>%
  summarise(
    water = round(mean(water_mismatch, na.rm = TRUE) * 100, 1),
    health = round(mean(health_mismatch, na.rm = TRUE) * 100, 1),
    electricity_fuel = round(mean(electricity_fuel_mismatch, na.rm = TRUE) * 100, 1),
    cash_access = round(mean(cash_access_mismatch, na.rm = TRUE) * 100, 1),
    n = n(),
    .groups = "drop"
  )

write_csv(
  urban_rural_mismatch,
  "results/tables/urban_rural_mismatch_rates.csv"
)

print(urban_rural_mismatch)

# -----------------------------
# 7. Country-level mismatch rates
# -----------------------------

country_mismatch_rates <- sadc_analysis %>%
  group_by(country_name) %>%
  summarise(
    water = round(mean(water_mismatch, na.rm = TRUE) * 100, 1),
    health = round(mean(health_mismatch, na.rm = TRUE) * 100, 1),
    electricity_fuel = round(mean(electricity_fuel_mismatch, na.rm = TRUE) * 100, 1),
    cash_access = round(mean(cash_access_mismatch, na.rm = TRUE) * 100, 1),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    average_mismatch = round(
      rowMeans(
        across(c(water, health, electricity_fuel, cash_access)),
        na.rm = TRUE
      ),
      1
    )
  ) %>%
  arrange(desc(average_mismatch)) %>%
  mutate(rank = row_number())

write_csv(
  country_mismatch_rates,
  "results/tables/country_mismatch_rankings.csv"
)

print(country_mismatch_rates)

# -----------------------------
# 8. Service hotspot table
# -----------------------------

service_hotspots <- country_mismatch_rates %>%
  select(
    country_name,
    water,
    health,
    electricity_fuel,
    cash_access
  ) %>%
  pivot_longer(
    cols = c(
      water,
      health,
      electricity_fuel,
      cash_access
    ),
    names_to = "service",
    values_to = "mismatch_rate_percent"
  ) %>%
  mutate(
    service = case_when(
      service == "water" ~ "Water",
      service == "health" ~ "Health",
      service == "electricity_fuel" ~ "Electricity/Fuel",
      service == "cash_access" ~ "Cash Access",
      TRUE ~ service
    )
  ) %>%
  arrange(desc(mismatch_rate_percent)) %>%
  mutate(rank = row_number())

write_csv(
  service_hotspots,
  "results/tables/service_hotspots.csv"
)

print(head(service_hotspots, 20))

# -----------------------------
# 9. Service presence vs severe shortage
# -----------------------------

service_presence_summary <- tibble(
  topic = c(
    "Water",
    "Health",
    "Electricity/Fuel",
    "Cash Access"
  ),
  
  severe_shortage_when_service_absent = c(
    mean(sadc_analysis$severe_water_shortage[sadc_analysis$piped_water_present == 0], na.rm = TRUE),
    mean(sadc_analysis$severe_medical_shortage[sadc_analysis$health_clinic_present == 0], na.rm = TRUE),
    mean(sadc_analysis$severe_fuel_shortage[sadc_analysis$electricity_grid_present == 0], na.rm = TRUE),
    mean(sadc_analysis$severe_cash_shortage[sadc_analysis$money_services_present == 0], na.rm = TRUE)
  ),
  
  severe_shortage_when_service_present = c(
    mean(sadc_analysis$severe_water_shortage[sadc_analysis$piped_water_present == 1], na.rm = TRUE),
    mean(sadc_analysis$severe_medical_shortage[sadc_analysis$health_clinic_present == 1], na.rm = TRUE),
    mean(sadc_analysis$severe_fuel_shortage[sadc_analysis$electricity_grid_present == 1], na.rm = TRUE),
    mean(sadc_analysis$severe_cash_shortage[sadc_analysis$money_services_present == 1], na.rm = TRUE)
  )
) %>%
  mutate(
    difference_present_minus_absent =
      severe_shortage_when_service_present -
      severe_shortage_when_service_absent,
    
    absent_percent = percent(
      severe_shortage_when_service_absent,
      accuracy = 0.1
    ),
    
    present_percent = percent(
      severe_shortage_when_service_present,
      accuracy = 0.1
    ),
    
    difference_percentage_points = round(
      difference_present_minus_absent * 100,
      1
    ),
    
    interpretation = case_when(
      difference_present_minus_absent < 0 ~
        "Severe shortage is lower where service is present",
      difference_present_minus_absent > 0 ~
        "Severe shortage is higher where service is present",
      difference_present_minus_absent == 0 ~
        "No difference",
      TRUE ~ NA_character_
    )
  )

write_csv(
  service_presence_summary,
  "results/tables/service_presence_vs_shortage.csv"
)

print(service_presence_summary)

# -----------------------------
# 10. Figure 1: Overall mismatch rate
# -----------------------------

plot_overall_mismatch <- ggplot(
  overall_mismatch_rates,
  aes(
    x = fct_reorder(service, mismatch_rate_percent),
    y = mismatch_rate_percent
  )
) +
  geom_col(fill = "#007C89") +
  geom_text(
    aes(label = paste0(mismatch_rate_percent, "%")),
    hjust = -0.1,
    size = 4
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(
      0,
      max(overall_mismatch_rates$mismatch_rate_percent, na.rm = TRUE) + 10
    )
  ) +
  labs(
    title = "Mismatch Rate by Service Type",
    subtitle = "Mismatch = service observed but severe shortage always reported",
    x = "Service Type",
    y = "Mismatch Rate (%)"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  "results/figures/figure_1_overall_mismatch_rate.png",
  plot = plot_overall_mismatch,
  width = 9,
  height = 6,
  dpi = 300
)

# -----------------------------
# 11. Figure 2: Urban-rural mismatch comparison
# -----------------------------

urban_rural_long <- urban_rural_mismatch %>%
  select(
    location_type,
    water,
    health,
    electricity_fuel,
    cash_access
  ) %>%
  pivot_longer(
    cols = c(
      water,
      health,
      electricity_fuel,
      cash_access
    ),
    names_to = "service",
    values_to = "mismatch_rate_percent"
  ) %>%
  mutate(
    service = case_when(
      service == "water" ~ "Water",
      service == "health" ~ "Health",
      service == "electricity_fuel" ~ "Electricity/Fuel",
      service == "cash_access" ~ "Cash Access",
      TRUE ~ service
    )
  )

plot_urban_rural <- ggplot(
  urban_rural_long,
  aes(
    x = service,
    y = mismatch_rate_percent,
    fill = location_type
  )
) +
  geom_col(position = position_dodge(width = 0.8)) +
  geom_text(
    aes(label = paste0(mismatch_rate_percent, "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.3,
    size = 3
  ) +
  scale_y_continuous(
    limits = c(
      0,
      max(urban_rural_long$mismatch_rate_percent, na.rm = TRUE) + 10
    )
  ) +
  labs(
    title = "Mismatch Rates by Location Type",
    subtitle = "Urban, peri-urban, and rural comparison",
    x = "Service Type",
    y = "Mismatch Rate (%)",
    fill = "Location"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  "results/figures/figure_2_urban_rural_mismatch.png",
  plot = plot_urban_rural,
  width = 10,
  height = 6,
  dpi = 300
)

# -----------------------------
# 12. Figure 3: Country ranking
# -----------------------------

plot_country_ranking <- ggplot(
  country_mismatch_rates,
  aes(
    x = fct_reorder(country_name, average_mismatch),
    y = average_mismatch
  )
) +
  geom_col(fill = "#003366") +
  geom_text(
    aes(label = paste0(average_mismatch, "%")),
    hjust = -0.1,
    size = 3.5
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(
      0,
      max(country_mismatch_rates$average_mismatch, na.rm = TRUE) + 10
    )
  ) +
  labs(
    title = "Country Ranking by Average Service-Shortage Mismatch",
    subtitle = "Average mismatch across water, health, electricity/fuel, and cash access",
    x = "Country",
    y = "Average Mismatch Rate (%)"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  "results/figures/figure_3_country_mismatch_ranking.png",
  plot = plot_country_ranking,
  width = 10,
  height = 7,
  dpi = 300
)

# -----------------------------
# 13. Figure 4: Country × service heatmap
# -----------------------------

country_heatmap_data <- country_mismatch_rates %>%
  select(
    country_name,
    average_mismatch,
    water,
    health,
    electricity_fuel,
    cash_access
  ) %>%
  pivot_longer(
    cols = c(
      water,
      health,
      electricity_fuel,
      cash_access
    ),
    names_to = "service",
    values_to = "mismatch_rate_percent"
  ) %>%
  mutate(
    service = case_when(
      service == "water" ~ "Water",
      service == "health" ~ "Health",
      service == "electricity_fuel" ~ "Electricity/Fuel",
      service == "cash_access" ~ "Cash Access",
      TRUE ~ service
    ),
    label = paste0(mismatch_rate_percent, "%")
  )

write_csv(
  country_heatmap_data,
  "results/tables/country_service_heatmap_data.csv"
)

plot_heatmap <- ggplot(
  country_heatmap_data,
  aes(
    x = service,
    y = fct_reorder(country_name, average_mismatch),
    fill = mismatch_rate_percent
  )
) +
  geom_tile(color = "white") +
  geom_text(
    aes(label = label),
    size = 3
  ) +
  scale_fill_gradient(
    low = "white",
    high = "darkred",
    labels = function(x) paste0(x, "%"),
    na.value = "grey90"
  ) +
  labs(
    title = "Country × Service Mismatch Heatmap",
    subtitle = "Darker cells show higher service-shortage mismatch",
    x = "Service Type",
    y = "Country",
    fill = "Mismatch Rate"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  "results/figures/figure_4_country_service_heatmap.png",
  plot = plot_heatmap,
  width = 10,
  height = 7,
  dpi = 300
)

# -----------------------------
# 14. Final console summary
# -----------------------------

cat("\n============================================================\n")
cat("DESCRIPTIVE ANALYSIS COMPLETE\n")
cat("============================================================\n")
cat("Definition used:\n")
cat("Severe shortage = Q6 value 4 only.\n")
cat("Mismatch = service present + severe related shortage.\n\n")

cat("Overall mismatch rates:\n")
print(overall_mismatch_rates)

cat("\nTables saved in results/tables/.\n")
cat("Figures saved in results/figures/.\n")
cat("============================================================\n")

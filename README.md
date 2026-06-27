# ici_template [This section can be removed in the submission version]
This GitHub repository offers a template specifically designed to teach students how to write effective README.md files and create a well-organized file structure. The template provides clear instructions and examples, helping students to learn the basics of GitHub and how to create professional-looking repositories.


# Project Title

[Enter the title of your project]

## Project Description

[Enter a brief description of your project, including the data you used and the analytical methods you applied. Be sure to provide context for your project and explain why it is important.]

## Getting Started

[Provide instructions on how to get started with your project, including any necessary software or data. Include installation instructions and any prerequisites or dependencies that are required.]

## File Structure

[Describe the file structure of your project, including how the files are organized and what each file contains. Be sure to explain the purpose of each file and how they are related to one another.]

## Analysis

[Describe your analysis methods and include any visualizations or graphics that you used to present your findings. Explain the insights that you gained from your analysis and how they relate to your research question or problem statement.]

## Results

[Provide a summary of your findings and conclusions, including any recommendations or implications for future research. Be sure to explain how your results address your research question or problem statement.]

## Contributors

[List the contributors to your project and describe their roles and responsibilities.]

## Acknowledgments

[Thank any individuals or organizations who provided support or assistance during your project, including funding sources or data providers.]

## References

[List any references or resources that you used during your project, including data sources, analytical methods, and tools.]










Public Service Visibility Paradox: Service Mismatches, Cascading Failures, and Public Service Priorities in SADC Countries

Project Description

This project investigates whether the visible presence of public infrastructure translates into effective public service delivery across countries in the Southern African Development Community (SADC). Although governments often measure development progress through infrastructure expansion, the presence of public facilities does not always guarantee that citizens can access services reliably.
The study introduces the Public Service Visibility Paradox, which describes situations where public infrastructure is visibly present but households still report severe shortages of the corresponding service. Using Afrobarometer Round 9 survey data from sixteen SADC countries, the project examines whether visible public services reduce severe deprivation, whether service failures cascade across interconnected sectors, and which services should be prioritised under limited public resources.
The empirical analysis combines descriptive statistics, visualisations, logistic regression, and Poisson regression to examine service visibility, service mismatches, cascading failures, urban–rural differences, governance comparisons, and public service priorities.

Getting Started

Software Requirements
The project was developed using R.
Recommended version:
R version 4.3 or later

Required R packages:
dplyr
tidyr
readr
haven
ggplot2
broom
sandwich
lmtest
forcats
purrr

Install the required packages using:
install.packages(c(
  "dplyr",
  "tidyr",
  "readr",
  "haven",
  "ggplot2",
  "broom",
  "sandwich",
  "lmtest",
  "forcats",
  "purrr"
))

Data

This project uses Afrobarometer Round 9 survey data.
Due to Afrobarometer's data-use policy, the raw dataset is not included in this repository. Users who wish to reproduce the analysis should obtain the dataset directly from Afrobarometer and place the raw data file in the following folder:
data/raw/

The scripts should be run in this order:
01_data_cleaning.R
02_descriptive_analysis.R
03_regressions.R


File Structure
Public-Service-Visibility-Paradox/

├── README.md
│
├── data/
│   ├── raw/
│   └── cleaned/
│
├── scripts/
│   ├── 01_data_cleaning.R
│   ├── 02_descriptive_analysis.R
│   └── 03_regressions.R
│
├── results/
│   ├── tables/
│   └── figures/visualizations
│
├── paper/
│   ├── Introduction_Chapter.docx
│   ├── Literature_Review.docx
│   ├── Regression_Analyses.docx
│   
│
└── presentation/
    └── Final_Presentation.pdf

Chapter and File Contents

Chapter 1 – Introduction and Research Questions
Introduces the research problem, study objectives, research questions, hypotheses, and overall organisation of the term paper.

Chapter 2 – Literature Review and Policy Context
Reviews the literature on public service delivery, governance, infrastructure effectiveness, interconnected service systems, and public-service prioritisation. It also develops the theoretical framework of the Public Service Visibility Paradox.

Chapter 3 – Data Description and Data Cleaning
Describes the Afrobarometer Round 9 dataset, data preparation procedures, variable construction, coding decisions, and data cleaning process implemented in R.

Chapter 4 – Descriptive Statistics and Visualisations
Presents descriptive statistics, summary tables, country comparisons, urban–rural analyses, mismatch rates, service hotspots, heatmaps, cascade diagrams, and priority charts.

Chapter 5 – Regression Analyses
Presents the regression component of the project, including model specification, model implementation, hypothesis testing, interpretation of regression results, and preparation of regression tables and empirical findings. The chapter uses logistic and Poisson regression models to examine whether visible public services reduce severe shortages, whether service mismatches cascade across interconnected public-service systems, and which services should be prioritised under limited public resources.

Chapter 6 – Discussion, Limitations, Policy Implications, and Conclusions
Interprets the empirical findings in relation to the literature, discusses the study's limitations, presents policy implications, summarises the main conclusions, and provides recommendations for future research.

Analysis
The project follows four main analytical stages.

1. Data Preparation
The Afrobarometer Round 9 dataset was merged, cleaned, and prepared for analysis. Variables were constructed to measure:
visible public services;
severe service shortages;
service mismatches;
urban–rural location;
country-level patterns.
Severe shortages are defined using the strictest Afrobarometer response category: respondents reporting that they always went without the corresponding service.

3. Descriptive Statistics and Visualisations
Descriptive analysis was used to examine:
overall service mismatch rates;
country-level comparisons;
urban–rural differences;
service hotspot rankings;
service presence versus severe shortages.
Visualisations were prepared to communicate key patterns, including heatmaps, cascade diagrams, and public-service priority charts.

5. Regression Analysis
Regression models were used to test the study hypotheses. The analysis includes:
logistic regression models for binary severe-shortage and mismatch outcomes;
Poisson regression models for the total number of severe shortages;
urban–rural comparison models;
country-specific governance comparison models.
The regression models evaluate whether visible infrastructure reduces severe shortages, whether service failures cascade across interconnected sectors, and which services should receive priority investment under limited public resources.

7. Interpretation and Policy Discussion
The final stage interprets the findings in relation to public service delivery, governance, infrastructure planning, and resource allocation. The project distinguishes between:
preventive services, which are associated with lower levels of severe deprivation; and
transmission mechanisms, which signal broader public-service fragility.

Results

The findings support the concept of the Public Service Visibility Paradox.
Visible public infrastructure is generally associated with lower probabilities of severe shortages, but infrastructure presence does not eliminate deprivation completely. Severe mismatches remain across all four service sectors examined.

The regression results show that piped water has the strongest preventive association with reducing severe shortages. Once service failures occur, Cash Access Mismatch functions as the strongest transmission mechanism linking failures across multiple public-service sectors. Health Clinic Mismatch also acts as an important secondary transmission pathway.
The findings suggest that governments should distinguish between services that primarily reduce deprivation and services that serve as early-warning indicators of broader public-service fragility when allocating limited public resources.

Contributors

Nsika Phepha Mbingo 113266014
Responsible for:
Chapter 1 – Introduction and Research Questions;
Chapter 2 – Literature Review and Policy Context;
Chapter 5 – Regression Analyses;
regression model specification and implementation;
hypothesis testing;
interpretation of regression results;
preparation of regression tables and empirical findings.

Nosipho Natiah Dlamini 113266018
Responsible for:
Chapter 3 – Data Description and Data Cleaning;
Chapter 4 – Descriptive Statistics and Visualisations;
Chapter 6 – Discussion, Limitations, Policy Implications, and Conclusions;
data merging and preparation;
data cleaning and variable construction;
descriptive statistics and visualisations;
final editing and formatting.

Joint Contributions

Both authors jointly contributed to:
development of the research topic and conceptual framework;
study design and planning;
review of analytical methods;
interpretation of the overall findings;
revision of the final manuscript;
final approval of the submitted term paper.

Acknowledgments
The authors gratefully acknowledge Afrobarometer for providing access to the Round 9 survey data used in this study.
We also express our sincere appreciation to Professor Pien Chung-pei, instructor of the Big Data Analysis course at National Chengchi University (NCCU), for his guidance, constructive feedback, and support throughout the development of this project.
The authors also acknowledge the use of ChatGPT by OpenAI as an AI-assisted tool for brainstorming, editing, coding support, documentation drafting, and improving the clarity of the final report and GitHub repository.
Finally, we acknowledge National Chengchi University for providing the academic environment and resources that made this project possible.



References

Afrobarometer. Afrobarometer Round 9 Survey Data.
Bratton, M., Seekings, J., & Armah-Attoh, D. (2019). Better but not good enough? How Africans see the delivery of public services.
Diallo, M. A., Azaglo, Y., & Ben Saad, M. N. (2026). Inadequate access and corruption mark public service delivery for many Africans.
Masuku, M. M., & Jili, N. N. (2019). Public service delivery in South Africa: The political influence at local government level.
McLoughlin, C., & Scott, Z. (2014). Service Delivery Topic Guide.



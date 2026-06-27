Public Service Visibility Paradox: Service Mismatches, Cascading Failures, and Public Service Priorities in SADC Countries

Project Description

This project investigates whether the visible presence of public infrastructure translates into effective public service delivery across countries in the Southern African Development Community (SADC). Although governments frequently evaluate development through infrastructure expansion, the presence of public facilities does not always guarantee reliable access to essential services.

The study introduces the **Public Service Visibility Paradox**, which describes situations where public infrastructure is visibly present but households continue to experience severe shortages of the corresponding service. Using **Afrobarometer Round 9** survey data from sixteen SADC countries, the project examines whether visible public services reduce severe deprivation, whether service failures cascade across interconnected public-service systems, and which services should be prioritised under limited public resources.

The empirical analysis combines descriptive statistics, data visualisations, logistic regression, and Poisson regression models to examine service visibility, service mismatches, cascading failures, governance differences, urban–rural disparities, and public service priorities.

Data

This project uses Afrobarometer Round 9 survey data.
Due to Afrobarometer's data-use policy, the raw dataset is not included in this repository. Users who wish to reproduce the analysis should obtain the dataset directly from Afrobarometer and place the raw data file in the following folder:
data/

Run the R scripts in the following order:

1. 01_data_cleaning.R
2. 02_descriptive_analysis.R
3. 03_regressions.R

---

 File Structure

Public-Service-Visibility-Paradox

│── README.md
│
├── data/
│   ├── raw
│
├── scripts/
│   ├── 01_data_cleaning.R
│   ├── 02_descriptive_analysis.R
│   └── 03_regressions.R
│
├── results/
│   └── figures
│
├── paper/
│   ├── Chapter_1_Introduction.docx
│   ├── Chapter_2_Literature_Review.docx
│   ├── Chapter_3_Data_Cleaning.docx
│   ├── Chapter_4_Descriptive_Statistics.docx
│   ├── Chapter_5_Regression_Analyses.docx
│   ├── Chapter_6_Visualisations.docx
│   ├── Chapter_7_Discussion_and_Conclusions.docx
│   └── Final_Term_Paper.pdf

Chapter Contents

Chapter 1 – Introduction, Research Questions, and Hypotheses**

Introduces the research problem, study objectives, research questions, hypotheses, and the Public Service Visibility Paradox.

Chapter 2 – Literature Review and Policy Context**

Reviews literature on public service delivery, governance, infrastructure effectiveness, interconnected public-service systems, and policy prioritisation while developing the study's theoretical framework.

Chapter 3 – Data Description and Data Cleaning**

Describes the Afrobarometer Round 9 dataset, data merging procedures, cleaning process, variable construction, and preparation of the analytical dataset in R.

Chapter 4 – Descriptive Statistics**

Presents descriptive statistics, country comparisons, urban–rural analyses, mismatch rates, and service hotspot rankings across the sixteen SADC countries.

Chapter 5 – Regression Analyses**

Presents the regression component of the project, including model specification, model implementation, hypothesis testing, interpretation of regression results, and preparation of regression tables and empirical findings. Logistic and Poisson regression models are used to evaluate the eight research hypotheses.

Chapter 6 – Visualisations**

Presents graphical summaries of the empirical findings, including mismatch charts, urban–rural comparisons, country rankings, heatmaps, cascade diagrams, and public-service priority charts.

Chapter 7 – Discussion, Policy Implications, and Conclusions**

Interprets the empirical findings, evaluates the hypotheses, discusses limitations, outlines policy implications, and presents the study's conclusions and recommendations for future research.

---

 Analysis

The project follows four analytical stages.

Stage 1 – Data Preparation

- Merge Afrobarometer country datasets
- Clean survey responses
- Construct service-presence variables
- Construct severe-shortage indicators
- Construct service-mismatch variables

Stage 2 – Descriptive Analysis

Descriptive statistics were used to examine:

- Overall mismatch rates
- Country-level comparisons
- Urban–rural differences
- Service hotspot rankings
- Relationships between visible infrastructure and severe shortages

These findings were illustrated using summary tables and visualisations.

Stage 3 – Regression Analysis

The empirical analysis employs logistic and Poisson regression models to evaluate eight research hypotheses concerning:

- Service Visibility
- Service Mismatch
- Cash Bottleneck
- Health Transmission
- Double Whammy
- Urban Trap
- Governance Frontier
- Public Service Priority

Stage 4 – Visualisation and Interpretation

The regression and descriptive findings are presented using:

- Country ranking charts
- Urban–rural comparison plots
- Heatmaps
- Service hotspot visualisations
- Cascade diagrams
- Public-service priority charts

These visualisations support interpretation of the statistical findings and highlight important policy patterns across SADC countries.

---

 Results

The findings provide empirical support for the **Public Service Visibility Paradox**.

Visible public infrastructure is generally associated with lower probabilities of severe shortages, but infrastructure presence alone does not eliminate deprivation. Significant service mismatches remain across all four service sectors examined.

Cash Access Mismatch records the highest mismatch rate and functions as the primary transmission mechanism linking failures across multiple public-service sectors. Health Clinic Mismatch also serves as an important secondary transmission pathway. Conversely, piped water emerges as the strongest preventive service, exhibiting the largest association with reducing severe shortages.

Overall, the results suggest that governments should distinguish between services that primarily reduce deprivation and services that act as early-warning indicators of broader public-service fragility when allocating limited public resources.

---

 Contributors

 Nsika Phepha Mbingo (113266014)

Responsible for:

- Chapter 1 – Introduction, Research Questions, and Hypotheses
- Chapter 2 – Literature Review and Policy Context
- Chapter 5 – Regression Analyses
- Regression model specification and implementation
- Hypothesis testing
- Interpretation of regression results
- Preparation of regression tables and empirical findings

 Nosipho Natiah Dlamini (113266018)

Responsible for:

- GitHub repository creation and organisation
- Chapter 3 – Data Description and Data Cleaning
- Chapter 4 – Descriptive Statistics
- Chapter 6 – Visualisations
- Chapter 7 – Discussion, Policy Implications, and Conclusions
- Data merging and preparation
- Data cleaning and variable construction
- Descriptive statistics and visualisations
- Final editing and formatting

Joint Contributions

Both authors jointly contributed to:

- Development of the research topic and conceptual framework
- Study design and planning
- Review of analytical methods
- Interpretation of the overall findings
- Revision of the final manuscript
- Final approval of the submitted project

---

Acknowledgments

The authors gratefully acknowledge **Afrobarometer** for providing access to the Round 9 survey data used in this study.

We express our sincere appreciation to **Professor Pien Chung-pei**, instructor of the **Big Data Analysis** course at National Chengchi University (NCCU), for his guidance, constructive feedback, and support throughout the development of this project.

The authors also acknowledge the use of **ChatGPT (OpenAI)** as an AI-assisted tool for brainstorming, coding support, editing, documentation, and improving the clarity of the final report and GitHub repository.

Finally, we acknowledge National Chengchi University (NCCU) for providing the academic environment and resources that made this research possible.

---

 References

Afrobarometer. *Afrobarometer Round 9 Survey Data.*

Bratton, M., Seekings, J., & Armah-Attoh, D. (2019). *Better but not good enough? How Africans see the delivery of public services.*

Diallo, M. A., Azaglo, Y., & Ben Saad, M. N. (2026). *Inadequate access and corruption mark public service delivery for many Africans.*

Masuku, M. M., & Jili, N. N. (2019). *Public service delivery in South Africa: The political influence at local government level.*

McLoughlin, C., & Scott, Z. (2014). *Service Delivery Topic Guide.*




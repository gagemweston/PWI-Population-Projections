# PWI Population Projections

[Population Wellbeing Initiative]([url](https://sites.utexas.edu/pwi/)) (PWI) projections and code on long-term global population

This program was last updated on **September 7, 2023**. It was primarily written by Gage Weston. You may contact Gage at gageweston@utexas.edu for issues or questions about the code.

**What is this program?**

This program uses python to run the cohort component method to project population from 2025 until any given date. You can define different 'treatments' which can alter the population size, fertility rates, or mortality rates and compare the effect of these treatments with the baseline projection where this treatment doesn't happen. We use fertility and mortality conditions from the 2022 United Nations World Population Prospects for projections from 2025 until 2100, after which the program generates its own figures which you can change using the code at the bottom of this section.

**This repository contains:**

1. **population_projections.ipynb**: A jupyter notebook containing the python code to run the projections alongside instructions for how to use this program. Run code in the section "Replicate Our Projections" to generate the CSV files below and to generate the figures in the appendix of our paper.
2. **figures.do**: Stata program that generates the figures from our paper using the CSV files in this repository.
3. **WPP_input_data.csv**: data on fertility, sex-specific mortality and population in 5-year age-groups and 5-year period from 2025-2100 from UN WPP zero-migration variant, re-formatted to be read by our program.
4. **main_output.csv**: population and births by period, age-group and asymptotic fertility scenario from 2025-3000
5. **rebound_output.csv**: population and births by period, age-group and asymptotic fertility scenario from 2025-3000 where TFR "rebounds" to replacement fertility at various years.
6. **appendix_output.csv**: population projections used for our appendix figures
7. **population_history.csv**: time-series of human global population and annual births (10,000 BCE to 2023 CE)

**About PWI**

PWI is an interdisciplinary research organization at University of Texas at Austin studying the long-term causes, consequences, and moral and political implications of low fertility and depopulation across the world.

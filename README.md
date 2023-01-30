# PWI Population Projections

[Population Wellbeing Initiative]([url](https://sites.utexas.edu/pwi/)) (PWI) projections and code on long-term global population

**What is this program?**

This program uses python to run the cohort component method to project population from 2025 until any given date. You can define different 'treatments' which can alter the population size, fertility rates, or mortality rates and compare the effect of these treatments with the baseline projection where this treatment doesn't happen. We use fertility and mortality conditions from the United Nations World Population Prospects from 2025 until 2100, after which the program generates its own figures which you can change using the code at the bottom of this section.

This program was last updated on **January 31, 2023**. It was primarily written by Gage Weston, a researcher at Population Wellbeing Initiative at University of Texas at Austin as of January 2023. You may contact Gage at gage@weston.co for issues or questions about the code.

**This repository contains:**
1. population_projections.ipynb: A jupyter notebook containing the python code to run the projections alongside instructions for how to use this program
2. WPP_input_data.csv: data on fertility, sex-specific mortality and population in 5-year age-groups and 5-year period from 2025-2100 from UN WPP zero-migration variant, re-formatted 

We did not include the output data files used in research we are working on related to this since the files would take up too much space. However, all projections we have shared publicly can be replicated using the files in this repository

**About PWI**
PWI is an interdisciplinary research organization at University of Texas at Austin studying the long-term causes, consequences, and moral and political implications of low fertility and depopulation across the world.

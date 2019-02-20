# gfishexplo
Groundfish Explorations

## Question: can adding recent catch allow increase in quota? Yes, maybe.

Premise is that missing catch, due to underestimated discards and/or improperly labelled landings could be the main source of retrospective patterns in recent groundfish stock assessments. This work explores this concept with the hypothesis that ABCs could be increased if this is true to offset management measures such as 100% observer coverage or dockside monitoring. 

## What was done?

A stock assessment that exhibited a strong retrospective pattern was used as a starting point. Catch multipliers were searched for that elimated the retrospective pattern for different starting years. These modified assessments were followed through to catch advice applying an F40% rule to compare with the original assessment and the original assessment with retrospective adjustment.

## Case Study 1: Witch Flounder (SARC 62, 2016)

The benchmark assessment for witch flounder at SARC 62 rejected the proposed ASAP model due to a strong retrospective pattern (https://www.nefsc.noaa.gov/publications/crd/crd1701/, https://www.nefsc.noaa.gov/publications/crd/crd1703/, and https://www.nefsc.noaa.gov/saw/saw62/sarc62_panel_summary_report.pdf). An ASAP file similar to the final run examined in SARC 62 was used as the starting point for this exercise. This assessment formulation used years 1982-2015, ages 1-11+, one fleet with three selectivity blocks, and five survey tuning indices (NESFS spring and fall scaled by the catchability study, ASMFC summer, and ME/NH spring and fall surveys). This assessment exhibited a strong retrospective pattern with Mohn's rho values of 0.64 and -0.46 for SSB and F, respectively.

![base retro](./witch/retro_F_SSB_R.png)

This strong retrospective pattern can be eliminated in many different ways. For this exercise, three starting years were selected for catch multipliers: 2000, 2005, and 2010. There was no a priori reason for selecting these years, they were selected to demonstrate a range of possible solutions and potential impact on catch advice. For each starting year, the catch for that year through 2015 was multiplied by a range of values (1.5, 2.0, 2.5, ..., 5.0) and the one that most reduced the retrospective pattern was selected. The magnitude of the catch multiplier needed to elminate the retrospective pattern varied with the starting year. Starting in 2000 required multiplying the catch by 5.0, while 2005 and 2010 required catch multipliers of 3.0 and 2.5, respectively. All three change year and catch multiplier combinations resulted in the Mohn's rho for SSB between -0.03 and 0.03, meaning essentialy eliminated. 

![rho vs catch mults](./witch/rhoplot.png)

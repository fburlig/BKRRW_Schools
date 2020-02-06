************************************************
**** MASTER DATA BUILD FILE (CALLS ALL BUILD FILES)
************************************************

*** Build electricity data (takes ~96 hours)
do "$dirpath_code_build/B01_MASTER_electricity_build.do"
 
*** Build weather data and collapse to monthly
do "$dirpath_code_build/B02_MASTER_weather_build_oct18.do" 
 
*** Build energy efficiency upgrade data
do "$dirpath_code_build/B03_MASTER_ee_data_build.do"

*** Merge school energy data with school EE data (step 1)
do "$dirpath_code_build/B04_MASTER_ee_energy_merge.do"

*** Merge school energy data with temperature data
do "$dirpath_code_build/B05_MASTER_merge_elec_temp.do"
 
*** Merge school energy + temperature data with school EE data (step 2)
do "$dirpath_code_build/B06_MASTER_cumul_ee_build.do"

*** Export data to R for machine learning
do "$dirpath_code_build/B07_MASTER_export_data_to_R.do"
 
***************************************************
***************************************************

*** (takes ~one week if bootstrap included)
di "need to run R here"
stop

***************************************************
***************************************************

*** Prepare treatment variables and some covariates
do "$dirpath_code_build/B08_MASTER_prep_treatment_vars.do" 

*** Read prediction data into Stata (takes ~24 hours if bootstrap included)
do "$dirpath_code_build/B09_MASTER_predictions_build.do"
 
*** Collapse predictions to the month-hour level; add covariates/samples; split by prediction type
do "$dirpath_code_build/B10_MASTER_predictions_monthly.do"

*** Generate a coastal-vs-inland indicator
do "$dirpath_code_build/B11_MASTER_is_coastal.do"

*** Generate a HVAC/Light treatment indicator for heterogeneity regressions
do "$dirpath_code_build/B12_MASTER_hvac_light_assignment.do"

*** Generate data for matching analysis // NEEDS SOME ATTENTION
do "$dirpath_code_build/B13_MASTER_matching.do"

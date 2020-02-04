************************************************
**** MASTER DATA BUILD FILE: BKRRW (2020)
************************************************

************************************************
**** SETUP:
clear all
set more off, perm
set type double
version 12

global dirpath "T:/Projects/Schools"
global dirpath_code "$dirpath/Github"
global dirpath_code_build "$dirpath_code/Build"
global dirpath_code_analyze "$dirpath_code/Analyze"
************************************************

*** Build electricity data (takes ~96 hours)
do "$dirpath_code_build/B01_MASTER_electricity_build.do"
 * current name: "$dirpath_code_build/MASTER_electricity_build_oct18.do"
 
*** Build weather data and collapse to monthly
do "$dirpath_code_build/B02_MASTER_weather_build_oct18.do" 
 * current name: "$dirpath_code_build/MASTER_weather_build_oct18.do"
 
*** Build energy efficiency upgrade data
do "$dirpath_code_build/B03_MASTER_ee_data_build.do"

*** Merge school energy data with school EE data (step 1)
do "$dirpath_code_build/B04_MASTER_ee_energy_merge.do"

*** Merge school energy data with temperature data
do "$dirpath_code_build/B05_MASTER_merge_elec_temp.do"
 * current name: "$dirpath_code_build/aug9_merge_elec_temp.do"
 
*** Merge school energy + temperature data with school EE data (step 2)
** CHECK ON ME, HAVING THIS TWICE SEEMS DUMB?
do "$dirpath_code_build/B06_MASTER_cumul_ee_build.do"
 * current name: "$dirpath_code_build/oct17_cumul_ee_build.do"
 
*** Label schools as HVAC/Lighting/both/neither (not sure we use this????)
do "$dirpath_code_build/B07_MASTER_build_pure_hvac_light.do" // consider renaming further?
 * current name: "$dirpath_code_build/build_pure_hvac_light.do"
 
*** Export data to R for machine learning
do "$dirpath_code_build/B08_MASTER_export_data_to_R.do"
 * current name: "$dirpath_code_build/aug9_TOR_schools.do"
 
*** Construct a preliminary analysis dataset (not sure we use this????)
do "$dirpath_code_build/B09_MASTER_temporary_build_for_jul6.do" // needs a further rename if we use it
 * current name: "$dirpath_code_build/TEMPORARY_build_for_jul6.do"
 
***************************************************
***************************************************

di "need to run R here"
stop

***************************************************
***************************************************

*** Read prediction data into Stata
do "$dirpath_code_build/B10_MASTER_predictions_build.do"
 * current name: "$dirpath_code_build/MASTER_predictions_build.do"

*** Merge constructed prediction data with cds_codes, generate some control vars
do "$dirpath_code_build/B11_MASTER_predictions_additions.do" // do we even use this now?
 * current name: "$dirpath_code_build/jun14_New_prediction_build.do"
 
*** Collapse predictions to the month-hour level; add covariates/samples; split by prediction type
do "$dirpath_code_build/B12_MASTER_predictions_monthly.do"
 * current name: "$dirpath_code_build/jun14_New_predition_build_monthly.do"

*** Generate a coastal-vs-inland indicator
do "$dirpath_code_build/B13_MASTER_is_coastal.do"
 * current name: "$dirpath_code_build/MASTER_is_coastal.do"



************************************************
************************************************
**** SETUP:
clear all
set more off, perm
set type double
version 12

global dirpath "T:/Projects/Schools"

** additional directory paths to make things easier
global dirpath_data "$dirpath/Data"
global dirpath_data_raw "$dirpath/Data/Raw"
global dirpath_data_int "$dirpath/Data/Intermediate"
global dirpath_data_final "$dirpath/Data/Final"
global dirpath_data_temp "$dirpath/Data/Temp"
global dirpath_data_other "$dirpath/Data/Other data"
global dirpath_results_prelim "$dirpath/Results/Preliminary"
************************************************

** Merge electricity data with school EE data
use "$dirpath_data_temp/ee_build_dataset_appended_AUGUST_nov5.dta", clear
append using "$dirpath_data_temp/ee_build_dataset_appended_AUGUST_OLDDATA.dta"
duplicates drop
* merge in the school identifiers
merge m:1 sp_id using "$dirpath_data_int/pge_lea_meter_crosswalk_oct2016.dta"
* only keep upgrades that merged (there are lots of 1's because
  * this dataset of ee upgrades comes from 3 PG&E data pulls
tab _merge
keep if _merge == 3
drop _merge
unique cds_code

* collapse upgrades of a given type that happen on the same date
egen fam_date_group = group(date_stata upgrade_tech_fam)
collapse(sum) incr_cost units adj_* incentives (mean) dupemeasure* project_life date_stata upgrade_tech_fam, by(cds_code fam_date_group)
label values upgrade_tech_fam techfam
format date_stata %td
keep cds_code upgrade_tech_fam date_stata incr_cost incentives adj_gross_kwh dupemeasure*
label define upgrcat 1 "Appliances" 2 "Boilers and steam systems" 3 "Building envelope" ///
  4 "Cross portfolio" 5 "Electronics and IT" 6 "Food service technology" 7 "HVAC" 8 "Lighting" ///
  9 "Motors, pumps, fans" 10 "Refrigeration" 11 "Unassigned"
label values upgrade_tech_fam upgrcat
save "$dirpath_data_int/ee_clean_elec_noclusters.dta", replace

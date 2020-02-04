		
************************************************
************************************************
**** SETUP:
clear all
set more off, perm
version 12

global dirpath "S:/Fiona/Schools"

** additional directory paths to make things easier
global dirpath_data "$dirpath/Data"
global dirpath_data_raw "$dirpath/Data/Raw"
global dirpath_data_int "$dirpath/Data/Intermediate"
global dirpath_data_final "$dirpath/Data/Final"
global dirpath_data_temp "$dirpath/Data/Temp"
global dirpath_data_other "$dirpath/Data/Other data"
global dirpath_results_prelim "$dirpath/Results/Preliminary"
************************************************

****** BUILDS CUMULATIVE EE DATA


use "$dirpath_data_int/ee_clean_elec_noclusters.dta", clear
replace dupemeasure = 0 if dupemeasure == .
duplicates drop
destring cds_code, replace
save "$dirpath_data_int/ee_clean_elec_noclusters_destr.dta", replace

use "$dirpath_data_int/MASTER_school_temp_merge.dta", clear
** GRAB THE FIRST SAMPLE DATE FOR EACH SCHOOL
drop if problematic==1
egen mindate = min(date), by(cds_code)
egen maxdate = max(date), by(cds_code)
keep cds_code mindate maxdate
duplicates drop 
*** MERGE IN TO ALL UPGRADES
merge 1:m cds_code using "$dirpath_data_int/ee_clean_elec_noclusters_destr.dta"
* keep only treated schools (control are irrelevant for this)
keep if _merge == 3



gen upgr_before_sample = 0
replace upgr_before_sample = 1 if date_stata < mindate & date_stata !=.

gen upgr_after_sample = 0
replace upgr_after_sample = 1 if date_stata > maxdate & date_stata !=.


drop _merge
format mindate %td

**** LARGEST UPGRADES
egen upgr_type_max = max(adj_gross_kwh), by(cds_code upgrade_tech_fam)
gen largest_upgr = 0
replace largest_upgr = 1  if adj_gross_kwh == upgr_type_max

**** LARGEST UPGRADES IN SAMPLE
egen upgr_type_max_samp = max(adj_gross_kwh) if upgr_before_sample == 0, by(cds_code upgrade_tech_fam)
gen largest_upgr_samp = 0
replace largest_upgr_samp = 1  if adj_gross_kwh == upgr_type_max


**** EARLIEST UPGRADES
egen upgr_type_first = min(date_stata), by(cds_code upgrade_tech_fam)
gen first_upgr = 0
replace first_upgr = 1 if date_stata == upgr_type_first

*** EARLIEST UPGRADES IN SAMPLE
egen upgr_type_first_samp = min(date_stata) if upgr_before_sample == 0, by(cds_code upgrade_tech_fam)
gen first_upgr_samp = 0
replace first_upgr_samp = 1 if date_stata == upgr_type_first_samp

save "$dirpath_data_int/ee_upgrades_all.dta", replace



use "$dirpath_data_int/MASTER_school_temp_merge.dta", clear
*drop if problematic==1
keep cds_code date
duplicates drop
save "$dirpath_data_temp/school_dates.dta", replace

keep cds_code date tot_kwh cumul_kwh kwh_frac tot_inc cumul_inc inc_frac dupemeasure* upgr_counter_hvac

replace dupemeasure = 0 if dupemeasure == .
duplicates drop
save "$dirpath_data_temp/ee_all_kwh_alldates_hvac.dta", replace


use "$dirpath_data_temp/ee_all_kwh_light.dta", clear
merge m:1 cds_code date using "$dirpath_data_temp/school_dates.dta", nogen keep(2 3)

sort cds_code date
by cds_code: carryforward cumul_kwh kwh_frac tot_kwh cumul_inc inc_frac tot_inc, replace

egen max_tot = max(tot_kwh), by(cds_code)
egen max_inc = max(tot_inc), by(cds_code)

gen evertreat = 0
replace evertreat = 1 if max_tot >0 & max_tot !=.

replace tot_kwh = max_tot if evertreat == 1 & tot_kwh == .
replace cumul_kwh = 0 if evertreat == 1 & cumul_kwh == .
replace kwh_frac = 0 if evertreat == 1 & kwh_frac == .

replace tot_kwh = 0 if evertreat == 0
replace cumul_kwh = 0 if evertreat == 0
replace kwh_frac = 0 if evertreat == 0


replace tot_inc = max_inc if evertreat == 1 & tot_inc == .
replace cumul_inc = 0 if evertreat == 1 & cumul_inc == .
replace inc_frac = 0 if evertreat == 1 & inc_frac == .

replace tot_inc = 0 if evertreat == 0
replace cumul_inc = 0 if evertreat == 0
replace inc_frac = 0 if evertreat == 0
keep cds_code date tot_kwh cumul_kwh kwh_frac tot_inc cumul_inc inc_frac dupemeasure* upgr_counter_light
replace dupemeasure = 0 if dupemeasure == .
duplicates drop
save "$dirpath_data_temp/ee_all_kwh_alldates_light.dta", replace

use "$dirpath_data_temp/ee_all_kwh_alldates.dta", clear
merge 1:1 cds_code date using "$dirpath_data_temp/ee_all_kwh_alldates_hvac.dta", nogen
merge 1:1 cds_code date using "$dirpath_data_temp/ee_all_kwh_alldates_light.dta", nogen

gen cumul_hvac_light = 0
replace cumul_hvac_light = cumul_kwh_hvac + cumul_kwh_light

gen tot_hvac_light = 0
replace tot_hvac_light = tot_kwh_hvac + tot_kwh_light

gen frac_hvac_light = 0
replace frac_hvac_light = cumul_hvac_light / tot_hvac_light


gen cumul_inc_hvac_light = 0
replace cumul_inc_hvac_light = cumul_inc_hvac + cumul_inc_light

gen tot_inc_hvac_light = 0
replace tot_inc_hvac_light = tot_inc_hvac + tot_inc_light

gen inc_frac_hvac_light = 0
replace inc_frac_hvac_light = cumul_inc_hvac_light / tot_inc_hvac_light



save "$dirpath_data_int/cumul_ee_upgrades_formerge.dta", replace


use "$dirpath_data_int/cumul_ee_upgrades_formerge.dta", clear
keep cds_code tot_* dupemeasure*
duplicates drop
replace dupemeasure = 0 if dupemeasure == .
collapse (max) dupe* (mean) tot*, by(cds_code)
isid cds_code
save "$dirpath_data_int/ee_total_formerge.dta", replace

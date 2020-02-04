************************************************
**** (HOPEFULLY) TEMPORARY DO FILE TO BUILD A MASTER ANALYSIS DATASET FOR 3/24
**** WRITTEN BY FIONA BURLIG (fiona.burlig@berkeley.edu)
**** CREATED: March 23, 2016
**** LAST EDITED: March 23, 2016

**** DESCRIPTION: This do-file prepares data for machine learning predictions.
			
**** NOTES: 
	
**** PROGRAMS:

**** CHOICES:
		
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
***** HOURLY DATA
use "$dirpath_data_int/MASTER_school_clean_merge.dta", clear
drop year zeroflag problematic month month_of_sample school_id

*** IMPORT CLIMATE ZONE
merge m:1 cds_code using "$dirpath_data_other/Demographics/cds_county_distr_forOFFLINE.dta", gen(_mschoolchar)
drop if _mschoolchar == 2
drop _mschoolchar
rename zip zipcode
merge m:1 zipcode using "$dirpath_data_other/Demographics/zip_to_climatezone.dta", gen(_mzipzone)
drop if _mzipzone == 2
drop _mzipzone district county zipcode

*** MERGE IN UPGRADE DATA
merge m:1 cds_code date using "$dirpath_data_int/cumul_ee_upgrades_formerge.dta", nogen

*** CREATE CUMULATIVE UPGRADE COUNTER
sort cds_code date block
by cds_code: carryforward upgr_counter_all upgr_counter_hvac upgr_counter_light, replace
replace upgr_counter_all = 0 if upgr_counter_all == .
replace upgr_counter_hvac = 0 if upgr_counter_hvac == .
replace upgr_counter_light = 0 if upgr_counter_light == .

gen month = month(date)

gen hvacpure_post_treat = .
replace hvacpure_post_treat = 0 if tot_kwh == 0
replace hvacpure_post_treat = 1 if cumul_kwh_hvac > 0 & cumul_kwh_hvac != . & cumul_kwh==cumul_kwh_hvac

gen lightpure_post_treat = .
replace lightpure_post_treat = 0 if tot_kwh == 0
replace lightpure_post_treat = 1 if cumul_kwh_light > 0 & cumul_kwh_light != . & cumul_kwh==cumul_kwh_light

compress

*** MERGE IN SIZE QUANTILES
preserve
   keep if any_post_treat == 0
   collapse(mean) qkw_hour, by(cds_code)
   rename qkw_hour mean_energy_use
   sum mean_energy_use, detail
   local pctile_25 = r(p25)
   local pctile_50 = r(p50)
   local pctile_75 = r(p75)
   
   gen kwh_quantile = .
   replace kwh_quantile = 1 if mean_energy_use >= 0 & mean_energy_use < `pctile_25'
   replace kwh_quantile = 2 if mean_energy_use >= `pctile_25' & mean_energy_use < `pctile_50'
   replace kwh_quantile = 3 if mean_energy_use >= `pctile_50' & mean_energy_use < `pctile_75'
   replace kwh_quantile = 4 if mean_energy_use >= `pctile_75' & mean_energy_use !=.   
   
   compress
   save "$dirpath_data_temp/mean_energy_use.dta", replace
restore

merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", nogen

preserve
keep date block cds_code qkw_hour temp_f tot_kwh cumul_kwh upgr_counter_all ///
	cumul_kwh_hvac upgr_counter_hvac cumul_kwh_light upgr_counter_light ///
	any_post_treat
compress
save "$dirpath_data_int/full_analysis_data_trimmed.dta", replace
restore

preserve
{
/*
**** ANY VERSION***
*** CREATE HOURLY TREATMENT DUMMIES
forvalues i = 0/23 {
  gen hour_x_post_any_`i' = 0
  replace hour_x_post_any_`i' = 1 if any_post_treat == 1 & hour == `i'
 
}
*** CREATE HOURLY TREATMENT DUMMIES INTERACTED WITH UPGRADE %
forvalues i = 0/23 {
  gen hour_x_post_any_`i'_frac = hour_x_post_any_`i' * kwh_frac
}
*** CREATE HOURLY TREATMENT DUMMIES INTERACTED WITH UPGRADE NUMBER
forvalues i = 0/23 {
  gen hour_x_post_any_`i'_counter = hour_x_post_any_`i' * upgr_counter_all
}
*/

gen savings_any = -(any_post_treat * tot_kwh) / (24 * 365)
compress
save "$dirpath_data_int/full_analysis_data_blocks_ANY.dta", replace
}
restore, preserve

/*
{
**** HVAC VERSION***
*** CREATE HOURLY TREATMENT DUMMIES
forvalues i = 0/23 {
  gen hour_x_post_hvac_`i' = 0
  replace hour_x_post_hvac_`i' = 1 if hvac_post_treat == 1 & hour == `i'
}
*** CREATE HOURLY TREATMENT DUMMIES INTERACTED WITH UPGRADE %
forvalues i = 0/23 {
  gen hour_x_post_hvac_`i'_frac = hour_x_post_hvac_`i' * kwh_frac_hvac
  gen hour_x_post_hvac_`i'_counter = hour_x_post_hvac_`i' * upgr_counter_hvac
}
gen savings_hvac = -(hvac_post_treat * tot_kwh_hvac) / (24 * 365)
compress
save "$dirpath_data_int/full_analysis_data_hours_HVAC.dta", replace
}
restore, preserve

{
**** LIGHT VERSION***
*** CREATE HOURLY TREATMENT DUMMIES
forvalues i = 0/23 {
  gen hour_x_post_light_`i' = 0
  replace hour_x_post_light_`i' = 1 if light_post_treat == 1 & hour == `i'
}
*** CREATE HOURLY TREATMENT DUMMIES INTERACTED WITH UPGRADE %
forvalues i = 0/23 {
  gen hour_x_post_light_`i'_frac = hour_x_post_light_`i' * kwh_frac_light
  gen hour_x_post_light_`i'_counter = hour_x_post_light_`i' * upgr_counter_light
}
gen savings_light = -(light_post_treat * tot_kwh_light) / (24 * 365)
compress
save "$dirpath_data_int/full_analysis_data_hours_light.dta", replace
}
restore
*/

/*
************** BLOCK-WISE
clear
use "$dirpath_data_int/full_analysis_data_hours_ANY.dta", clear

gen block = 0
replace block = 1 if hour >= 0 & hour <= 2
replace block = 2 if hour >= 3 & hour <= 5
replace block = 3 if hour >= 6 & hour <= 8
replace block = 4 if hour >= 9 & hour <= 11
replace block = 5 if hour >= 12 & hour <= 14
replace block = 6 if hour >= 15 & hour <= 17
replace block = 7 if hour >= 18 & hour <= 20
replace block = 8 if hour >= 21 & hour <= 23

collapse(mean) qkw_hour temp_f tot_kwh kwh_quantile ///
  cumul_kwh* kwh_frac* any_post_treat savings_any upgr_*, ///
  by(cds_code date block climatezone)

gen log_kwh = ln(qkw_hour)

forvalues i = 1/8 {
  gen block_x_post_any_`i' = 0
  replace block_x_post_any_`i' = 1 if any_post_treat == 1 & block == `i'
  }


forvalues i = 1/8 {
  gen block_x_post_any_`i'_frac = block_x_post_any_`i' * kwh_frac
  gen block_x_post_any_`i'_counter = block_x_post_any_`i' * upgr_counter_all
}
  
label var any_post_treat "Any x post"

label var cumul_kwh "Cumulative projected savings"
label var kwh_frac "Cumulative/total projected savings"
label var cumul_kwh_light "Cumulative projected savings"
label var kwh_frac_light "Cumulative/total projected savings"
label var cumul_kwh_hvac "Cumulative projected savings"
label var kwh_frac_hvac "Cumulative/total projected savings"


label var block_x_post_any_1 "Midn. to 2 AM x post"
label var block_x_post_any_2 "3 AM to 5 AM x post"
label var block_x_post_any_3 "6 AM to 8 AM x post"
label var block_x_post_any_4 "9 AM to 11 AM x post"
label var block_x_post_any_5 "Noon to 2 PM x post"
label var block_x_post_any_6 "3 PM to 5 PM x post"
label var block_x_post_any_7 "6 PM to 8 PM x post"
label var block_x_post_any_8 "9 PM to 11 PM x post"

label var block_x_post_any_1_frac "Midn. to 2 AM x post  x fraction"
label var block_x_post_any_2_frac "3 AM to 5 AM x post  x fraction"
label var block_x_post_any_3_frac "6 AM to 8 AM x post  x fraction"
label var block_x_post_any_4_frac "9 AM to 11 AM x post  x fraction"
label var block_x_post_any_5_frac "Noon to 2 PM x post  x fraction"
label var block_x_post_any_6_frac "3 PM to 5 PM x post  x fraction"
label var block_x_post_any_7_frac "6 PM to 8 PM x post  x fraction"
label var block_x_post_any_8_frac "9 PM to 11 PM x post  x fraction"

compress
save "$dirpath_data_int/full_analysis_data_blocks_any.dta", replace  
  
  
clear
use "$dirpath_data_int/full_analysis_data_hours_light.dta", clear

gen block = 0
replace block = 1 if hour >= 0 & hour <= 2
replace block = 2 if hour >= 3 & hour <= 5
replace block = 3 if hour >= 6 & hour <= 8
replace block = 4 if hour >= 9 & hour <= 11
replace block = 5 if hour >= 12 & hour <= 14
replace block = 6 if hour >= 15 & hour <= 17
replace block = 7 if hour >= 18 & hour <= 20
replace block = 8 if hour >= 21 & hour <= 23

collapse(mean) qkw_hour temp_f tot_kwh kwh_quantile ///
  cumul_kwh* kwh_frac* any_post_treat light_post_treat savings_light upgr_counter*, ///
  by(cds_code date block climatezone)

gen log_kwh = ln(qkw_hour)

forvalues i = 1/8 {
  gen block_x_post_light_`i' = 0
  replace block_x_post_light_`i' = 1 if light_post_treat == 1 & block == `i'
  }

forvalues i = 1/8 {
  gen block_x_post_light_`i'_frac = block_x_post_light_`i' * kwh_frac_light
    gen block_x_post_light_`i'_counter = block_x_post_light_`i' * upgr_counter_light

}
  
label var light_post_treat "Light x post"

label var cumul_kwh "Cumulative projected savings"
label var kwh_frac "Cumulative/total projected savings"
label var cumul_kwh_light "Cumulative projected savings"
label var kwh_frac_light "Cumulative/total projected savings"

label var block_x_post_light_1 "Midn. to 2 AM x post"
label var block_x_post_light_2 "3 AM to 5 AM x post"
label var block_x_post_light_3 "6 AM to 8 AM x post"
label var block_x_post_light_4 "9 AM to 11 AM x post"
label var block_x_post_light_5 "Noon to 2 PM x post"
label var block_x_post_light_6 "3 PM to 5 PM x post"
label var block_x_post_light_7 "6 PM to 8 PM x post"
label var block_x_post_light_8 "9 PM to 11 PM x post"

label var block_x_post_light_1_frac "Midn. to 2 AM x post x fraction"
label var block_x_post_light_2_frac "3 AM to 5 AM x post x fraction"
label var block_x_post_light_3_frac "6 AM to 8 AM x post x fraction"
label var block_x_post_light_4_frac "9 AM to 11 AM x post x fraction"
label var block_x_post_light_5_frac "Noon to 2 PM x post x fraction"
label var block_x_post_light_6_frac "3 PM to 5 PM x post x fraction"
label var block_x_post_light_7_frac "6 PM to 8 PM x post x fraction"
label var block_x_post_light_8_frac "9 PM to 11 PM x post x fraction"

compress
save "$dirpath_data_int/full_analysis_data_blocks_light.dta", replace  


 
clear
use "$dirpath_data_int/full_analysis_data_hours_HVAC.dta", clear

cap rename savings_any savings_hvac

gen block = 0
replace block = 1 if hour >= 0 & hour <= 2
replace block = 2 if hour >= 3 & hour <= 5
replace block = 3 if hour >= 6 & hour <= 8
replace block = 4 if hour >= 9 & hour <= 11
replace block = 5 if hour >= 12 & hour <= 14
replace block = 6 if hour >= 15 & hour <= 17
replace block = 7 if hour >= 18 & hour <= 20
replace block = 8 if hour >= 21 & hour <= 23

collapse(mean) qkw_hour temp_f tot_kwh kwh_quantile ///
  cumul_kwh* kwh_frac* any_post_treat hvac_post_treat savings_hvac upgr_counter*, ///
  by(cds_code date block climatezone)

gen log_kwh = ln(qkw_hour)
  
forvalues i = 1/8 {
  gen block_x_post_hvac_`i' = 0
  replace block_x_post_hvac_`i' = 1 if hvac_post_treat == 1 & block == `i'
  }


forvalues i = 1/8 {
  gen block_x_post_hvac_`i'_frac = block_x_post_hvac_`i' * kwh_frac_hvac
    gen block_x_post_hvac_`i'_counter = block_x_post_hvac_`i' * upgr_counter_hvac

}

  
label var hvac_post_treat "hvac x post"

label var cumul_kwh "Cumulative projected savings"
label var kwh_frac "Cumulative/total projected savings"
label var cumul_kwh_hvac "Cumulative projected savings"
label var kwh_frac_hvac "Cumulative/total projected savings"

label var block_x_post_hvac_1 "Midn. to 2 AM x post"
label var block_x_post_hvac_2 "3 AM to 5 AM x post"
label var block_x_post_hvac_3 "6 AM to 8 AM x post"
label var block_x_post_hvac_4 "9 AM to 11 AM x post"
label var block_x_post_hvac_5 "Noon to 2 PM x post"
label var block_x_post_hvac_6 "3 PM to 5 PM x post"
label var block_x_post_hvac_7 "6 PM to 8 PM x post"
label var block_x_post_hvac_8 "9 PM to 11 PM x post"

label var block_x_post_hvac_1_frac "Midn. to 2 AM x post x fraction"
label var block_x_post_hvac_2_frac "3 AM to 5 AM x post x fraction"
label var block_x_post_hvac_3_frac "6 AM to 8 AM x post x fraction"
label var block_x_post_hvac_4_frac "9 AM to 11 AM x post x fraction"
label var block_x_post_hvac_5_frac "Noon to 2 PM x post x fraction"
label var block_x_post_hvac_6_frac "3 PM to 5 PM x post x fraction"
label var block_x_post_hvac_7_frac "6 PM to 8 PM x post x fraction"
label var block_x_post_hvac_8_frac "9 PM to 11 PM x post x fraction"

compress
save "$dirpath_data_int/full_analysis_data_blocks_hvac.dta", replace  
*/

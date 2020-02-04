************************************************
**** RUNNING MAIN TABLE REGRESSIONS
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
set type double
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

foreach dataset in "_by_block" {

use "$dirpath_data_int/schools_predictions`dataset'.dta", clear

keep date block school_id prediction* train*

* drop unbalanced days
cap drop numblocks
bys school_id date: gen numblocks=_N
drop if numblocks!=24

* drop schools with less than two months of data
cap drop numobs
sort school_id date block
by school_id: gen numobs = _N
drop if numobs < 24*60

* posttrain control
gen posttrain = 1 - trainindex

drop numobs* numblocks trainindex 

gen date_s = date(date, "YMD")
drop date
rename date_s date

merge m:1 school_id using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", keep(3) nogen
drop school_id

* drop tiny schools
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", nogen keep(3)
drop if mean_energy_use < 1.5 

sort cds_code
by cds_code: gen obs = _n
summ mean_energy_use if obs == 1, det

gen sample2 = 1
replace sample2 = 0 if mean_energy_use < `r(p1)' & mean_energy_use != .
replace sample2 = 0 if mean_energy_use > `r(p99)' & mean_energy_use != .

drop mean_energy_use kwh_quantile obs

* generate some relevant controls
gen year = year(date)
gen month = month(date)
egen month_of_sample = group(year month)

compress
save "$dirpath_data_temp/newpred_formerge`dataset'.dta", replace

use "$dirpath_data_temp/newpred_formerge`dataset'.dta", clear
merge 1:1 cds_code date block using "$dirpath_data_int/full_analysis_data_blocks_any.dta", keep(3) nogen
compress
save "$dirpath_data_temp/full_blocks_any_newpred`dataset'.dta", replace

}

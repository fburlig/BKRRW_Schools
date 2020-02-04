		
************************************************
************************************************
**** SETUP:
clear all
set more off, perm
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

use "$dirpath_data_temp/monthly_by_block4_sample0.dta", clear
keep cds_code
duplicates drop

merge 1:1 cds_code using  "$dirpath_data_other/Demographics/cds_county_distr_forOFFLINE.dta", keep(3) nogen

rename zip zipcode
merge m:1 zipcode using  "$dirpath_data_other/Demographics/zip_to_climatezone.dta", keep(3) nogen

gen coastal = 0
replace coastal = 1 if climate == 1 | climate == 3 | climate == 5

keep cds_code coastal

save "$dirpath_data_temp/cds_coastal.dta", replace

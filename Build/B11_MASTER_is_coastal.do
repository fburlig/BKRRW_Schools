************************************************
**** BUILD INLAND/COASTAL INDICATOR
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

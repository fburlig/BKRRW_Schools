************************************************
**** LABEL SCHOOLS BY EE UPGRADE TYPES (DEFUNCT???)
************************************************

use "$dirpath_data_int/cumul_ee_upgrades_formerge.dta", clear

gen hvac_only = 0
replace hvac_only = 1 if tot_kwh == tot_kwh_hvac & tot_kwh_light == 0 & tot_kwh_hvac != 0
unique cds_code if hvac_only==1

gen light_only = 0
replace light_only = 1 if tot_kwh == tot_kwh_light & tot_kwh_hvac == 0 & tot_kwh_light != 0
unique cds_code if light_only==1

gen hvac = 0
replace hvac = 1 if tot_kwh_hvac > 0 & tot_kwh_hvac != .
unique cds_code if hvac==1

gen light = 0
replace light = 1 if tot_kwh_light > 0 & tot_kwh_light != .
unique cds_code if light==1

gen control = 0
replace control = 1 if tot_kwh == 0
unique cds_code if control==1

keep cds_code hvac_only light_only hvac light control

duplicates drop

sort cds_code
save "$dirpath_data_int/hvac_light_pure.dta", replace


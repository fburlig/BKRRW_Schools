************************************************
**** MERGE ELECTRICITY AND TEMPERATURE DATA
************************************************


************************************************
** STEP 1: Merge temperature & electricity data
use "$dirpath_data_int/pge_electricity_MASTER_oct2016.dta", clear
destring cds_code, replace
merge 1:1 cds_code date hour using "$dirpath_data_int/school_weather_MASTER.dta"
drop if _merge == 2
label var temp_f "Temperature (F)"
drop _merge

************************************************
** STEP 2: Setting up some variables we might want for regressions
* kwh in logs
gen log_kwh = ln(qkw_hour)
label variable log_kwh "Ln(kwh)"

* some time vars
gen month = month(date)
gen year = year(date)
egen month_of_sample = group(year month)

compress
save "$dirpath_data_int/MASTER_school_temp_merge.dta", replace

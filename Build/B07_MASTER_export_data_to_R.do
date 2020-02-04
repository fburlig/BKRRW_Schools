************************************************
**** PREPARE DATA FOR EXPORT TO R
************************************************

use "$dirpath_data_int/MASTER_school_temp_merge.dta", clear

*generate a school ID and time
egen school_id = group(cds_code)
preserve
  keep school_id cds_code
  duplicates drop
  save "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", replace
restore
egen time = group(date hour)

* missing dates for schools (now showing up as 0)
drop if qkw_hour==0 & zeroflag==0 & problematic==1

* replace other problematic with missing
replace qkw_hour = . if problematic==1

* tsset to interpolate problematic values if only one missing
tsset school_id time
tsfill
by school_id: ipolate qkw_hour time, gen(qkw_hour_new) 
tsspell, cond(missing(qkw_hour))
egen length = max(_seq), by(school_id _spell)
replace qkw_hour_new = . if length > 2 
replace qkw_hour = qkw_hour_new if problematic_obs==1
replace problematic_obs=0 if qkw_hour != .
drop qkw_hour_new _spell _end length

merge m:1 cds_code date using "$dirpath_data_int/cumul_ee_upgrades_formerge.dta", keep(3)

gen byte any_post_treat = 0
replace any_post_treat = 1 if cumul_kwh > 0 & cumul_kwh != .

gen byte hvac_post_treat = 0
replace hvac_post_treat = 1 if cumul_kwh_hvac > 0 & cumul_kwh_hvac != .

gen byte light_post_treat = 0
replace light_post_treat = 1 if cumul_kwh_light > 0 & cumul_kwh_light != .

gen byte evertreated_any = 0
replace evertreated_any = 1 if tot_kwh > 0 & tot_kwh != .

collapse(mean) qkw_hour problematic zero meter temp_f /// 
  evertreated_any *_post_treat tot* cumul* frac* dupemeasure* ///
  upgr_counter*, by(cds_code date hour school_id month year month_of_sample)
rename hour block

replace problematic_obs = 0 if problematic_obs < .9

drop if problematic != 0
drop if qkw_hour==. 
gen log_kwh = log(qkw_hour)

compress
save "$dirpath_data_int/MASTER_school_clean_merge.dta", replace

sort school_id date block
by school_id date: gen numblocks=_N
drop if numblocks!=24

summ school_id
local school_max = r(max)
preserve
forvalues i = 1/`school_max' {
  keep if school_id == `i'
  save "$dirpath_data_schoolspec/school_data_block_`i'.dta", replace 
  restore
  drop if school_id == `i'
  preserve
}
restore

************************************************

* generate control schools data for synthetic control
clear 
forvalues  i = 1/`school_max' {
	cap append using "$dirpath_data_schoolspec/school_data_block_`i'.dta"
	cap keep if evertreated_any==0
	cap keep school_id date block qkw evertreated_any
}
drop evertreated_any
summ school_id
local school_max = r(max)
local school_min = r(min)
reshape wide qkw, i(date block) j(school_id)
rename qkw* cqkw*

egen time = group(date block)
tsset time
foreach var of varlist cqkw_hour`school_min'-cqkw_hour`school_max' {
	* iterpolate controls some more for LASSO
	csipolate `var' time, gen(`var'_i)
	tsspell, cond(missing(`var'))
	egen length = max(_seq), by(_spell)
	replace `var'_i = . if length > 5
	drop `var' _spell _seq length _end
	rename `var'_i `var'
}

keep date block cqkw*

export delimited using "$dirpath_data/Other data/ControlSchoolsLASSO/control_schools.csv", replace

* clean up
clear
memory clear

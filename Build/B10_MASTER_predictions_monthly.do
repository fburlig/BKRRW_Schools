************************************************
**** PREP PREDICTIONS DATA AND COLLAPSE TO MONTH-HOUR
************************************************

********************************************************************************
* Clean predictions and merge with temperature and upgrade variables

use "$dirpath_data_int/schools_predictions_by_block.dta", clear

rename qkw prediction_error0

keep date block school_id prediction* train*

* drop unbalanced days
gsort school_id date block
by school_id date: gen numblocks=_N
drop if numblocks!=24

* drop schools with less than two months of data
by school_id: gen numobs = _N
drop if numobs < 24*60

* posttrain control
gen byte posttrain = 1 - trainindex

drop numobs* numblocks trainindex 

gen date_s = date(date, "YMD")
drop date
rename date_s date

* reshape long
keep prediction_error? prediction_error_treat? prediction_error_bs* date block school_id posttrain

gen prediction_error10 = (prediction_error1 + prediction_error2+prediction_error3+prediction_error4+prediction_error7+prediction_error8+prediction_error9)/7

merge m:1 school_id using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", keep(3) nogen
drop school_id

* drop tiny schools
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", nogen keep(3)
drop if mean_energy_use < 1.5
drop mean_energy_use kwh_quantile

* generate some relevant controls
gen int year = year(date)
gen byte month = month(date)
gegen month_of_sample = group(year month)

compress
save "$dirpath_data_temp/newpred_formerge_by_block.dta", replace

use "$dirpath_data_temp/newpred_formerge_by_block.dta", clear
merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen
compress

save "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", replace

********************************************************************************
** CREATE SUBSAMPLE VARIABLES and MONTHLY COLLAPSE

use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear
gen byte sample0 = 1

merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
bys cds_code: gen obs = _n

gen byte sample2 = 1
summ mean_energy_use if obs == 1, det
replace sample2 = 0 if mean_energy_use < `r(p1)' & mean_energy_use != .
replace sample2 = 0 if mean_energy_use > `r(p99)' & mean_energy_use != .

gen byte sample6 = 1
summ tot_kwh if obs == 1 & tot_kwh !=0, det
replace sample6 = 0 if tot_kwh < `r(p1)' & tot_kwh != 0
replace sample6 = 0 if tot_kwh > `r(p99)' & tot_kwh != 0

gen byte evertreated = 0
replace evertreated = 1 if tot_kwh > 0 & tot_kwh !=.

keep prediction_error* qkw* evertreated any_post_treat ///
	posttrain tot* cumul* upgr* cds_code block month year ///
	month_of_sample sample*

gsort evertreated posttrain

* adding bootstrap predictions
local bslist = ""
forvalues bs = 1(1)20 {
	local bslist = "`bslist' _bs`bs'"
}
foreach pred in 0 1 2 3 4 7 8 9 10 `bslist' {
	di "`pred'"
	** CREATE MONTHLY FILES AND APPEND
	foreach subsample in 0 2 3 6 12 13 {
	
		if (`subsample'!=0 & `subsample'!=3 & strmatch("`pred'","_bs*")) {
			continue
		}
		preserve
		
		keep prediction_error*`pred' qkw* evertreated any_post_treat posttrain tot* cumul* upgr* cds_code block month year month_of_sample sample*
		
		if (`subsample'==3 | `subsample'==12) {
			gen byte sample3 = 0
			gegen p1_error = pctile(prediction_error`pred'), p(1) by(evertreated posttrain) 
			gegen p99_error = pctile(prediction_error`pred'), p(99) by(evertreated posttrain)
			replace sample3 = 1 if prediction_error`pred' > p1_error & prediction_error`pred' < p99_error
			drop p1_error p99_error
		}
		if `subsample'==13 {
			gen byte sample13 = 0
			gegen p2_error = pctile(prediction_error`pred'), p(2) by(evertreated posttrain)
			gegen p98_error = pctile(prediction_error`pred'), p(98) by(evertreated posttrain)
			replace sample13 = 1 if prediction_error`pred' > p2_error & prediction_error`pred' < p98_error
			drop p2_error p98_error
		}
		if `subsample'==12 {
			gen byte sample12 = sample3 * sample6
		}
		keep if sample`subsample'==1
		
		gen byte numobs = 1
		gcollapse (mean) prediction_error*`pred' qkw* tot* cumul* upgr* ///
			(sum) numobs, by(cds_code block month year month_of_sample any_post_treat posttrain)
		rename prediction_error`pred' prediction_error
		
		gen byte sample = `subsample'
		compress
		save "$dirpath_data_temp/monthly_by_block`pred'_sample`subsample'.dta", replace
		
		restore
	}
}

************************************************
**** ANALYSIS: R^2 ACROSS PREDICTION METHODS
************************************************

use "$dirpath_data_temp/newpred_formerge_by_block.dta", clear
merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen

keep cds_code block posttrain date qkw prediction_error* any_post_treat

gen log_kwh = log(qkw)

gegen byte treatment_school = max(any_post_treat), by(cds_code)
gen byte treatment_on = 0
replace treatment_on = 1 if treatment_school == 1 &  posttrain == 1

gegen groupid = group(cds_code block posttrain)

gegen p2mean = mean(qkw), by(groupid) 
gen y2 = (qkw-p2mean)^2

gegen p2meanlog = mean(log_kwh), by(groupid) 
gen y2_log = (log_kwh-p2meanlog)^2
		
forvalues i = 1(1)8{
foreach v in "prediction_error" "prediction_error_log" {
		
		local depvar = "`v'`i'"
		
		local tail = ""
		if "`v'" == "prediction_error_log" {
			local tail = "_log"
		}
		
		* clean up outlier
		gquantiles _p_error = `depvar', xtile nquantiles(100) by(groupid) strict
		*bysort groupid: egen _p_error = rank(`depvar') 
		*bysort groupid: replace _p_error = ceil(100 * _p_error/_N)
		replace `depvar' = . if _p_error == 1 | _p_error == 100
		drop _p_error

		gegen e2mean = mean(`depvar'), by(groupid) 
		gen e2`tail'`i'= (`depvar'-e2mean)^2
		drop e2mean
		
}
}

* create variables for correlaion
foreach var of varlist prediction_error? prediction_error_log?  {
	gen sd_`var' = `var'
}

* collapse data before and after   corr_*
gcollapse (mean) prediction_error* (sd) sd* (sum) e2* y2*, by(cds_code treatment_school block posttrain)

* r2 by school-block-posttrain
foreach tail in "" "_log" {
forvalues i = 1(1)8{
	gen r2`tail'`i' = 1 - e2`tail'`i'/y2`tail'
	drop e2`tail'`i'
}
}
drop y2*

save "$dirpath_data_int/varied_ml_methods_r2_post.dta", replace

************************************************
**** ANALYSIS: ML ESTIMATORS (PRE-POST, TU, ETC)
************************************************

**** Clean up prediction:
local dataset = "_by_block"
use "$dirpath_data_temp/newpred_formerge`dataset'.dta", clear
drop prediction*bs*

merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen

egen treatment_school = max(any_post_treat), by(cds_code)
gsort cds_code posttrain date

gen treatment_on = posttrain*treatment_school

gen sample0 = 1

keep date block month month_of_sample cds_code prediction* ///
		posttrain treatment* sample*
order cds_code date block month month_of_sample prediction* posttrain treatment* sample*

compress

gen treat_x_post = treatment_school * posttrain

** set up variables for regression outputs
cap drop yvar-r2
gen yvar = ""
gen ylab = ""
gen fe = ""
gen clustering = ""
gen controls = ""
gen subsample = ""
gen postctrls = ""
gen method = ""
gen beta_aggregate = .
gen se_aggregate = .

gen nobs = .
gen nschools = .
gen r2 = .
gen spec_desc = ""

************************************************

gsort treatment_school posttrain cds_code
local row = 1

**** alternative estimators
foreach spec in 1 2 3 4 7 8 9 10 {

local depvar = "prediction_error`spec'"

* update sample3 definition
cap drop sample3
gen byte sample3 = 0
gegen p1_error = pctile(`depvar'), p(1) by(treatment_school posttrain)
gegen p99_error = pctile(`depvar'), p(99) by(treatment_school posttrain)
replace sample3 = 1 if `depvar' > p1_error & `depvar' < p99_error
drop p1_error p99_error

foreach i in 0 3 {
	
		replace yvar = "`depvar'" in `row'
		
		* prediction error control
		qui reg prediction_error`spec' if sample`i' == 1 & treatment_school == 0 & posttrain == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[_cons] in `row'
		replace se_aggregate = _se[_cons] in `row'
		
		replace spec_desc = "bc" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment
		qui reg prediction_error`spec' if sample`i' == 1 & treatment_school == 1 & posttrain == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[_cons] in `row'
		replace se_aggregate = _se[_cons] in `row'

		replace spec_desc = "bt" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment and control post
		qui reg prediction_error`spec' treatment_school if sample`i' == 1 & posttrain == 1, vce(cluster cds_code)			
		
		replace beta_aggregate = _b[treatment_school] in `row'
		replace se_aggregate = _se[treatment_school] in `row'

		replace spec_desc = "bdd" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment with before control
		qui reg prediction_error`spec' posttrain if sample`i' == 1 & treatment_school == 0, vce(cluster cds_code)
		replace beta_aggregate = _b[posttrain] in `row'
		replace se_aggregate = _se[posttrain] in `row'
		
		replace spec_desc = "bcd" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment with before control
		qui reg prediction_error`spec' treatment_on if sample`i' == 1 & treatment_school == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[treatment_on] in `row'
		replace se_aggregate = _se[treatment_on] in `row'

		replace nobs = e(N) in `row'
		replace spec_desc = "btd" in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		* prediction error treatment and control pre and post
		qui reg prediction_error`spec'  treatment_school##posttrain if sample`i' == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[1.posttrain#1.treatment_school] in `row'
		replace se_aggregate = _se[1.posttrain#1.treatment_school] in `row'

		replace nobs = e(N) in `row'
		replace spec_desc = "b3d" in `row'
		replace subsample = "`i'" in `row'
		replace method = "`spec'"
		local row = `row' + 1
}
}

keep if spec_desc != ""


keep beta* se* spec_desc nobs subsample

save "$dirpath_data_int/RESULTS_ml_estimators_levels_samples.dta", replace



************************************************
* This file reads in the predictions from R

* Treatment predictions do not seem to be working well (train vs test)
* some also only have treated observations -- KEY TO FIGURE OUT

************************************************
**** SETUP:
clear all
memory clear
set more off, perm
version 12

global dirpath "S:/Fiona/Schools"

** additional directory paths to make things easier
global dirpath_data "$dirpath/Data"
global dirpath_data_raw "$dirpath/Data/Raw"
global dirpath_data_int "$dirpath/Data/Intermediate"
global dirpath_data_final "$dirpath/Data/Final"
global dirpath_data_temp "$dirpath/Data/Temp"
global dirpath_results_prelim "$dirpath/Results/Preliminary"


************************************************

**** Clean up prediction:
local dataset = "_by_block"
use "$dirpath_data_temp/newpred_formerge`dataset'.dta", clear
merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen

egen treatment_school = max(any_post_treat), by(cds_code)
sort cds_code posttrain date

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

sort treatment_school posttrain cds_code
local row = 1

**** alternative estimators
forvalues spec = 1(1)8 {

local depvar = "prediction_error`spec'"

* update sample1 definition
cap drop sample1
gen sample1 = 0
by treatment_school posttrain cds_code: egen p1_error = pctile(`depvar'), p(1)
by treatment_school posttrain cds_code: egen p99_error = pctile(`depvar'), p(99)
replace sample1 = 1 if `depvar' > p1_error & `depvar' < p99_error
drop p1_error p99_error

* update sample3 definition
cap drop sample3
gen sample3 = 0
by treatment_school posttrain: egen p1_error = pctile(`depvar'), p(1)
by treatment_school posttrain: egen p99_error = pctile(`depvar'), p(99)
replace sample3 = 1 if `depvar' > p1_error & `depvar' < p99_error
drop p1_error p99_error

foreach i in 0 1 3 {
	
		replace yvar = "`depvar'" in `row'
		
		* prediction error control
		qui reg prediction_error`spec' if sample`i' == 1 & treatment_school == 0 & posttrain == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[_cons] in `row'
		replace se_aggregate = _se[_cons] in `row'
		
		/*
		qui reg prediction_error`spec' block_? ///
				if sample`i' == 1 & treatment_school == 0 & posttrain == 1, ///
				vce(cluster cds_code) nocons
		forvalues j = 1/8 {
		replace beta_block`j' = _b[block_`j'] in `row'
		replace se_block`j' = _se[block_`j'] in `row'
		}
		*/
		replace spec_desc = "bc" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment
		qui reg prediction_error`spec' if sample`i' == 1 & treatment_school == 1 & posttrain == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[_cons] in `row'
		replace se_aggregate = _se[_cons] in `row'
		/*
		qui reg prediction_error`spec' block_? ///
				if sample`i' == 1 & treatment_school == 1 & posttrain == 1, ///
				vce(cluster cds_code) nocons
		forvalues j = 1/8 {
		replace beta_block`j' = _b[block_`j'] in `row'
		replace se_block`j' = _se[block_`j'] in `row'
		}
		*/
		replace spec_desc = "bt" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		* prediction error treatment and control post
		qui reg prediction_error`spec' treatment_school if sample`i' == 1 & posttrain == 1, vce(cluster cds_code)			
		
		replace beta_aggregate = _b[treatment_school] in `row'
		replace se_aggregate = _se[treatment_school] in `row'
		/*
		qui reghdfe prediction_error`spec' block_?_x_post ///
				if sample`i' == 1 & posttrain == 1, ///
				absorb(block) vce(cluster cds_code) fast tol(0.0001)
		forvalues j = 1/8 {
		replace beta_block`j' = _b[block_`j'_x_post] in `row'
		replace se_block`j' = _se[block_`j'_x_post] in `row'
		}
		*/
		replace spec_desc = "bdd" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment with before control
		qui reg prediction_error`spec' posttrain if sample`i' == 1 & treatment_school == 0, vce(cluster cds_code)
		replace beta_aggregate = _b[posttrain] in `row'
		replace se_aggregate = _se[posttrain] in `row'
		
		/*
		qui reghdfe prediction_error`spec' block_?_x_posttrain ///
				if sample`i' == 1 & treatment_school == 0, ///
				absorb(block) vce(cluster cds_code) fast tol(0.0001)
		
		forvalues j = 1/8 {
		replace beta_block`j' = _b[block_`j'_x_posttrain] in `row'
		replace se_block`j' = _se[block_`j'_x_posttrain] in `row'
		}
		*/
		replace spec_desc = "bcd" in `row'
		replace nobs = e(N) in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		
		* prediction error treatment with before control
		qui reg prediction_error`spec' treatment_on if sample`i' == 1 & treatment_school == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[treatment_on] in `row'
		replace se_aggregate = _se[treatment_on] in `row'
		
		/*
		qui reghdfe prediction_error`spec' block_?_x_post ///
				if sample`i' == 1 & treatment_school == 1, ///
				absorb(block) vce(cluster cds_code) fast tol(0.0001)
			
		forvalues j = 1/8 {
		replace beta_block`j' = _b[block_`j'_x_post] in `row'
		replace se_block`j' = _se[block_`j'_x_post] in `row'
		}
		*/
		replace nobs = e(N) in `row'
		replace spec_desc = "btd" in `row'
		replace subsample = "`i'" in `row'
		local row = `row' + 1
		
		* prediction error treatment and control pre and post
		qui reg prediction_error`spec'  treatment_school##posttrain if sample`i' == 1, vce(cluster cds_code)
		replace beta_aggregate = _b[1.posttrain#1.treatment_school] in `row'
		replace se_aggregate = _se[1.posttrain#1.treatment_school] in `row'

		/*
		qui reghdfe prediction_error`spec' block_?_x_post ///
				if sample`i' == 1, ///
				absorb(block##posttrain) vce(cluster cds_code) fast tol(0.0001)
		forvalues j = 1/8 {
		replace beta_block`j' = _b[block_`j'_x_post] in `row'
		replace se_block`j' = _se[block_`j'_x_post] in `row'
	    }
		*/
		replace nobs = e(N) in `row'
		replace spec_desc = "b3d" in `row'
		replace subsample = "`i'" in `row'
		replace method = "`spec'"
		local row = `row' + 1
}
}

keep if spec_desc != ""

gen tscore_aggregate = beta_aggregate / se_aggregate
gen pvalue_aggregate = 2*normal(-abs(tscore_aggregate))
gen stars_aggregate = "^{*}" if pvalue_aggregate < 0.1
replace stars_aggregate = "^{**}" if pvalue_aggregate < 0.05
replace stars_aggregate = "^{***}" if pvalue_aggregate < 0.01
gen ci95_lo_aggregate = beta_aggregate - 1.96*se_aggregate
gen ci95_hi_aggregate = beta_aggregate + 1.96*se_aggregate
/*
forvalues i = 1/8 {
  gen tscore_block`i' = beta_block`i' / se_block`i'
  gen pvalue_block`i' = 2*normal(-abs(tscore_block`i'))
  gen stars_block`i' = "^{*}" if pvalue_block`i' < 0.1
  replace stars_block`i' = "^{**}" if pvalue_block`i' < 0.05
  replace stars_block`i' = "^{***}" if pvalue_block`i' < 0.01
  gen ci95_lo_block`i' = beta_block`i' - 1.96 * se_block`i'
  gen ci95_hi_block`i' = beta_block`i' + 1.96 * se_block`i'
}
*/

keep beta* se* tscore* pvalue* stars* ci95* spec_desc nobs subsample

save "$dirpath_data_int/RESULTS_ml_estimators_levels_samples.dta", replace


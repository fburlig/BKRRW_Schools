************************************************
**** RUNNING REGRESSIONS MAIN RESULTS
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

** set up variables for regression outputs
gen yvar = ""
gen ylab = ""
gen xvar = ""
gen fe = ""
gen clustering = ""
gen controls = ""
gen subsample = ""
gen postctrls = ""
gen spec = .
gen beta_aggregate = .
gen se_aggregate = .
gen davis_denominator = .
gen davis_denominator2 = .
gen nobs = .
gen nschools = .
gen r2 = .
set obs 20000

local row = 1
* adding bootstrap predictions
local bslist = ""
forvalues bs = 1(1)20 {
	local bslist = "`bslist' _bs`bs'"
}

* 
foreach depvar in 0 1 2 3 4 7 8 9 `bslist' {
foreach subsample in 0 2 3 6 12 13 {
foreach postctrls in  "" "post" {
  foreach blocks in any_post_treat {
   foreach spec in c f i m h j {
	 {
	 
	 if (`subsample'!=0 & `subsample'!=3 & strmatch("`depvar'","_bs*")) {
	 	continue
	 }
	 /* if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 } */
	 local ctrls = ""
	 local clstrs = "cds_code"
	  if "`spec'" == "c" {
       local fes = "cds_code#prediction block#prediction"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "f" {
       local fes = "cds_code#block#prediction"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "h" {
       local fes = "cds_code#block#prediction month_of_sample#prediction"
	   replace spec = 5 in `row'   
      }
      else if "`spec'" == "i" {
       local fes = "cds_code#block#month#prediction"
	   replace spec = 3 in `row'
      }
	  else if "`spec'" == "j" {
       local fes = "cds_code#block#month#prediction month_of_sample#prediction"
	   replace spec = 6 in `row'
      } 
      else if "`spec'" == "m" {
	   local ctrls = "c.month_of_sample#prediction"
	   local fes = "cds_code#block#month#prediction"
	   replace spec = 4 in `row'
	  }
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain#prediction"
	  }	
	 }

	  di "`row'"

		  preserve
		 
		  if ("`depvar'"=="11") {
			use "$dirpath_data_temp/monthly_by_block4_sample`subsample'.dta", clear
		    gen prediction = 1			
			append using "$dirpath_data_temp/monthly_by_block10_sample`subsample'.dta"
			replace prediction = 2 if prediction==.
		  }
		  else {
			use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
		    gen prediction = 1			
		  }
		  
		  if ("`depvar'"=="9") {
			replace any_post_treat = prediction_error_treat9
		  }

		  keep if prediction_error != . & cumul_kwh != .
		  
		  * Davis denominator
		  qui reghdfe cumul_kwh `blocks' `ctrls' if prediction_error != . [fw=numobs], absorb(`fes') tol(0.001)
		  gen davis = -_b[`blocks']/(24*365)
		  egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
		  replace davis2 = -davis2/(24*365)
		  qui summ davis
		  local davis = r(mean)
		  qui summ davis2
		  local davis2 = r(mean)
		  
		  * Main regressions
		  qui reghdfe prediction_error `blocks' `ctrls' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  
		  restore 
		  
		  if ("`depvar'"=="0") {
		  	replace yvar = "qkw_hour" in `row'
		  }
		  else {
			replace yvar = "prediction_error`depvar'" in `row'
		  }
		  if ("`blocks'"=="any_post_treat") {
			replace xvar = "davis binary" in `row'
		  }
		  else if ("`blocks'"=="upgr_counter_all") {
			replace xvar = "davis continuous (counter)" in `row'
		  }
		  
		  if "`depvar'" == "0" {
			replace ylab = "Electricity consumption (kWh)" in `row'
		  }
		  if "`depvar'" == "1" {
			replace ylab = "Prediction error (kWh), no ctrl schools - Min" in `row'
		  }
		  if "`depvar'" == "2" {
			replace ylab = "Prediction error (kWh), no ctrl schools - 1SE" in `row'
		  }
		  if "`depvar'" == "3" {
			replace ylab = "Prediction error (kWh) - Min" in `row'
		  }
		  if "`depvar'" == "4" {
			replace ylab = "Prediction error (kWh) - Baseline" in `row'
		  }
		  if "`depvar'" == "5" {
			replace ylab = "Prediction error (kWh) ctrls only - Min" in `row'
		  }
		  if "`depvar'" == "6" {
			replace ylab = "Prediction error (kWh) ctrls only - Min" in `row'
		  }
		  if "`depvar'" == "7" {
			replace ylab = "Prediction error (kWh) - blockwise Forest" in `row'
		  }
		  if "`depvar'" == "8" {
			replace ylab = "Prediction error (kWh) - Forest" in `row'
		  }
		  if "`depvar'" == "9" {
			replace ylab = "Prediction error (kWh) - Double Lasso" in `row'
		  }
		  if "`depvar'" == "10" {
			replace ylab = "Prediction error (kWh) - Post" in `row'
		  }
		  if "`depvar'" == "11" {
			replace ylab = "Prediction error (kWh) - Pre/Post" in `row'
		  }		  
		  
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace beta_aggregate = _b[`blocks'] in `row'
		  replace se_aggregate = _se[`blocks'] in `row'
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace r2 = e(r2) in `row'
		  replace davis_denominator = `davis' in `row'
		  replace davis_denominator2 = `davis2' in `row'
			
		  local row = `row' + 1
	  
	  }
  }
}
}
}

keep yvar - r2
keep if yvar != ""
gen tscore_aggregate = beta_aggregate / se_aggregate
gen pvalue_aggregate = 2*normal(-abs(tscore_aggregate))
gen stars_aggregate = "^{*}" if pvalue_aggregate < 0.1
replace stars_aggregate = "^{**}" if pvalue_aggregate < 0.05
replace stars_aggregate = "^{***}" if pvalue_aggregate < 0.01
gen ci95_lo_aggregate = beta_aggregate - 1.96*se_aggregate
gen ci95_hi_aggregate = beta_aggregate + 1.96*se_aggregate

save "$dirpath_data_int/RESULTS_monthly_allml_models.dta", replace

gen rate = beta_aggregate / davis_denominator
gen rate2 = beta_aggregate / davis_denominator2
br yvar fe controls beta_aggregate rate*

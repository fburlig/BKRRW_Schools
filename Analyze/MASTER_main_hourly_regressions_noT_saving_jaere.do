************************************************
**** ANALYSIS: HOURLY REGRESSIONS WITH SAVINGS
************************************************

use "$dirpath_data_temp/newpred_formerge_by_block.dta", clear
merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen
keep block prediction_error0 prediction_error4 date cds_code month month_of_sample  temp_f any_post_treat cumul_kwh
	  
		  
** CREATE SUBSAMPLE VARIABLES
gen sample0 = 1

merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
bys cds_code: gen obs = _n

keep block prediction_error0 prediction_error4 cds_code month month_of_sample  temp_f any_post_treat cumul_kwh sample*
		  
tempfile analysisdata
save "`analysisdata'"		  
		  

clear

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
gen se_mos = .
gen davis_denominator = .
gen davis_denominator2 = .
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
foreach depvar in 0 4 {
foreach subsample in 0 {
foreach postctrls in  "" "post" {
  foreach blocks in any_post_treat cumul_kwh_binary {
   foreach spec in c f i m h j {
	 {
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	 
	 local ctrls = ""
	 local clstrs = "cds_code"
	  if "`spec'" == "c" {
       local fes = "cds_code block"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "f" {
       local fes = "cds_code#block"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "h" {
       local fes = "cds_code#block month_of_sample"
	   replace spec = 5 in `row'   
      }
      else if "`spec'" == "i" {
       local fes = "cds_code#block#month"
	   replace spec = 3 in `row'
      }
	  else if "`spec'" == "j" {
       local fes = "cds_code#block#month month_of_sample"
	   replace spec = 6 in `row'
      } 
      else if "`spec'" == "m" {
	   local ctrls = "c.month_of_sample"
	   local fes = "cds_code#block#month"
	   replace spec = 4 in `row'
	  }
	  local ifs = ""
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	 }
	 local fes = "`fes'"

	  di "`row'"

		  preserve
		 

		  use "`analysisdata'", clear
		  
		  keep if sample`subsample' == 1
		  drop sample*
		  
		  if ("`depvar'"=="9") {
			replace any_post_treat = prediction_error_treat9
		  }
		  
		  else if ("`depvar'" == "0") {
		    gen prediction_error = prediction_error0
			drop prediction_error4
		   }
		  else if ("`depvar'" == "4") {
		    gen prediction_error = prediction_error4
			drop prediction_error0
		   }
		  
		  
		  * Davis estimator
		  replace cumul_kwh = - cumul_kwh / (24*365)
		  by cds_code: egen cumul_kwh_binary = mean(cumul_kwh) if cumul_kwh < 0
		  replace cumul_kwh_binary = 0 if cumul_kwh_binary == .
		  
		  local davis = .
		  if (strmatch("`blocks'","any_post_treat")) {
			qui reghdfe cumul_kwh_binary `blocks' `ctrls' , absorb(`fes') tol(0.001)
			local davis = _b[`blocks']
		  }
		  if (strmatch("`blocks'","upgr_counter_all")) {
			qui reghdfe cumul_kwh `blocks' `ctrls' , absorb(`fes') tol(0.001)
			local davis = _b[`blocks']
		  }

		  qui reghdfe prediction_error `blocks' `ctrls' `ifs', absorb(`fes') tol(0.001) cluster(`clstrs')
		  restore 
		  
		  if (`depvar'==0) {
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
		  else if ("`blocks'"=="cumul_kwh_binary") {
			replace xvar = "reguant binary" in `row'
		  }
		  
		  if "`depvar'" == "0" {
			replace ylab = "Energy consumption (kWh)" in `row'
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

save "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta", replace

gen rate = beta_aggregate / davis_denominator
gen rate2 = beta_aggregate / davis_denominator2
br yvar fe controls beta_aggregate rate*

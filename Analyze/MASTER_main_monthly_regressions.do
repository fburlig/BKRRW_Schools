************************************************
**** ANALYSIS: MONTHLY REGRESSIONS
************************************************


** set up variables for regression outputs
clear
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
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
foreach depvar in 0 1 2 3 4 7 8 9 10 {
foreach subsample in 0 3 6 12 13 {
foreach postctrls in "" "post" {
  foreach blocks in any_post_treat upgr_counter_all cumul_kwh_binary cumul_kwh {
   foreach spec in f i m h j {
	 {

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
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	 }

	  di "`row'"

		  preserve
		 
		  use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
		  
		  * Davis estimator
		  replace cumul_kwh = - cumul_kwh / (24*365)
		  by cds_code: egen cumul_kwh_binary = wtmean(cumul_kwh) if cumul_kwh < 0, weight(numobs)
		  replace cumul_kwh_binary = 0 if cumul_kwh_binary == .
		  
		  local davis = .
		  if (strmatch("`blocks'","any_post_treat")) {
			qui reghdfe cumul_kwh_binary `blocks' `ctrls' [fw=numobs], absorb(`fes') tol(0.001)
			local davis = _b[`blocks']
		  }
		  if (strmatch("`blocks'","upgr_counter_all")) {
			qui reghdfe cumul_kwh `blocks' `ctrls' [fw=numobs], absorb(`fes') tol(0.001)
			local davis = _b[`blocks']
		  }
		  
		  * Regressions
		  qui reghdfe prediction_error `blocks' `ctrls' [fw=numobs], absorb(`fes') tol(0.001) cluster(cds_code month_of_sample)
		  local se_mos = _se[`blocks']
		  
		  qui reghdfe prediction_error `blocks' `ctrls' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  
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
		  
		  if "`depvar'" == "0" {
			replace ylab = "Electricity consumption (kWh)" in `row'
		  }
		  if "`depvar'" == "3" {
			replace ylab = "Prediction error (kWh) - Min" in `row'
		  }
		  if "`depvar'" == "4" {
			replace ylab = "Prediction error (kWh) - Baseline" in `row'
		  }
		  if "`depvar'" == "7" {
			replace ylab = "Prediction error (kWh) - Forest" in `row'
		  }
		  if "`depvar'" == "7" {
			replace ylab = "Prediction error (kWh) - Forest Joint" in `row'
		  }
		  if "`depvar'" == "9" {
			replace ylab = "Prediction error (kWh) - Double Lasso" in `row'
		  }
		  if "`depvar'" == "10" {
			replace ylab = "Prediction error (kWh) - Average" in `row'
		  }  
		  
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace beta_aggregate = _b[`blocks'] in `row'
		  replace se_aggregate = _se[`blocks'] in `row'
		  replace se_mos = `se_mos' in `row'
		  replace davis_denominator = `davis' in `row'
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace r2 = e(r2) in `row'
			
		  local row = `row' + 1
	  
	  }
  }
}
}
}

keep yvar - r2
keep if yvar != ""
gen rate = beta_aggregate / davis_denominator
save "$dirpath_data_int/RESULTS_monthly.dta", replace

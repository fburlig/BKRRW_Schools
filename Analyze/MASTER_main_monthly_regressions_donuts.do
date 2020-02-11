************************************************
**** ANALYSIS: MONTHLY REGRESSIONS WITH DONUTS
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
gen davis_denominator = .
gen nobs = .
gen nschools = .
gen donuts = .
gen r2 = .
set obs 2000

local row = 1
foreach donuts in 1 2 3 {
foreach depvar in 0 4 /*7 9 10 11*/ {
foreach subsample in 0 /*3 6 12 13 */ {
foreach postctrls in "" "post" {
  foreach blocks in any_post_treat cumul_kwh_binary {
   foreach spec in f i m h j k {
	 {
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	 if (`depvar' == 4) & ("`spec'" == "k") {
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
      else if "`spec'" == "k" {
	   local ctrls = ""
	   local fes = "cds_code#block#month month_of_sample cds_code##c.daily_t_max cds_code##c.daily_t_min cds_code##c.daily_t_mean "
	   replace spec = 7 in `row'
	  }
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	 }

	  di "`row'"

		  preserve
		 
		  use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
		  // this is a m:1 merge because we collapse by posttrain
		  merge m:1 cds_code year month block using "$dirpath_data_int/school_weather_MASTER_monthly.dta", keep(3)

		  egen treat_month_prelim = min(month_of_sample) if posttrain == 1, by(cds_code)
		  egen treat_month = mean(treat_month_prelim), by(cds_code)
		
		  gen months_to_treat = month_of_sample - treat_month
		  		  
		  drop if months_to_treat < `donuts' & months_to_treat > -`donuts'

		  drop treat_month* months_to 
		  
		  sort cds_code
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
		  else if ("`blocks'"=="cumul_kwh_binary") {
			replace xvar = "savings binary" in `row'
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
		  replace davis_denominator = `davis' in `row'
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace r2 = e(r2) in `row'
		  replace donuts = `donuts' in `row'
			
		  local row = `row' + 1
	  }
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

save "$dirpath_data_int/RESULTS_monthly_DONUTS.dta", replace

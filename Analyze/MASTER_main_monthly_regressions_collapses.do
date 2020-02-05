************************************************
**** ANALYSIS: COLLAPSED TO THE MONTH LEVEL
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
gen se_mos = .
gen davis_denominator = .
gen collapse = ""
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
foreach depvar in 0 4 {
foreach subsample in 0 {
foreach postctrls in "" "post" {
  foreach blocks in any_post_treat cumul_kwh_binary {
   foreach spec in c f i m h j {
    foreach collapse in month year {
	
	{
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	 
	 
	 if "`collapse'" == "month" {
	 local ctrls = ""
	 local clstrs = "cds_code"
	  if "`spec'" == "c" {
       local fes = "cds_code"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "f" {
       local fes = "cds_code"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "h" {
       local fes = "cds_code month_of_sample"
	   replace spec = 5 in `row'   
      }
      else if "`spec'" == "i" {
       local fes = "cds_code#month"
	   replace spec = 3 in `row'
      }
	  else if "`spec'" == "j" {
       local fes = "cds_code#month month_of_sample"
	   replace spec = 6 in `row'
      } 
      else if "`spec'" == "m" {
	   local ctrls = "c.month_of_sample"
	   local fes = "cds_code#month"
	   replace spec = 4 in `row'
	  }
	  local ifs = ""
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	 }
	 
	 
	 if "`collapse'" == "year" {
	 local ctrls = ""
	 local clstrs = "cds_code"
	  if "`spec'" == "c" {
       local fes = "cds_code"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "f" {
       local fes = "cds_code"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "h" {
       local fes = "cds_code year"
	   replace spec = 5 in `row'   
      }
      else if "`spec'" == "i" {
	  /*
       local fes = "cds_code#year#prediction"
	   replace spec = 3 in `row'
	   */
	   continue
      }
	  else if "`spec'" == "j" {
	  /*
       local fes = "cds_code#year#prediction year#prediction"
	   replace spec = 6 in `row'
	   */
	   continue
      } 
      else if "`spec'" == "m" {
	  /*
	   local ctrls = "c.month_of_sample#prediction"
	   local fes = "cds_code#year#prediction"
	   replace spec = 4 in `row'
	   */
	   continue
	  }
	  local ifs = ""
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	 }
	 
	 
	 
	 
	 }

	  di "`row'"

		  preserve
		 
		  if ("`depvar'"=="11") {
			use "$dirpath_data_temp/monthly_by_block4_sample`subsample'.dta", clear
			append using "$dirpath_data_temp/monthly_by_block10_sample`subsample'.dta"
		  }
		  else {
			use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
		  }
		  
		  if ("`depvar'"=="9") {
			replace any_post_treat = prediction_error_treat9
		  }
		  
		  sort  cds_code
		  by  cds_code: egen avg_savings_prelim = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
		  egen cumul_kwh_binary = mean(avg_savings_prelim), by(cds_code)
		  replace cumul_kwh_binary = 0 if cumul_kwh_binary == .
		  replace cumul_kwh_binary = cumul_kwh_binary*any_post_treat
		  drop avg_savings_prelim

		  replace cumul_kwh = -cumul_kwh/(24*365)
		  replace cumul_kwh_binary = -cumul_kwh_binary/(24*365) 

		  * Davis estimator
		  qui reghdfe cumul_kwh `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001)
		  gen davis = -_b[`blocks']/(24*365)
		  qui summ davis
		  local davis = r(mean)
		  
		  qui reghdfe prediction_error `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  local nobs = e(N)
		  
		  if "`collapse'" == "month" {
		   gcollapse (mean) prediction_error*`pred' qkw* any_post_treat posttrain tot* cumul* upgr* ///
			(sum) numobs, by(cds_code month year month_of_sample)
		  }
		  if "`collapse'" == "year" {
		   gcollapse (mean) prediction_error*`pred' qkw* any_post_treat posttrain tot* cumul* upgr* ///
			(sum) numobs, by(cds_code year)
		  }
		  
		  
		  * Regressions
		  
		  qui reghdfe prediction_error `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  /* old code
		  if ("`blocks'"=="any_post_treat") {
			egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			replace davis2 = -davis2/(24*365)
		  }
		  else if ("`blocks'"=="upgr_counter_all") {
			egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			replace davis2 = -davis2/(24*365)
			egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			egen count_temp  = wtmean(upgr_counter_all) if cumul_kwh > 0, weight(numobs)
			replace davis2 = davis/count_temp
			replace davis2 = -davis/(24*365)
			drop count_temp
		  }
		  */
		  
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
		  *replace se_mos = `se_mos' in `row'
		  replace davis_denominator = `davis' in `row'
		  replace nobs = `nobs' in `row'
		  replace nschools = e(N_clust) in `row'
		  replace collapse = "`collapse'" in `row'
		  replace r2 = e(r2) in `row'
			
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

replace davis = davis * -(365*24)

save "$dirpath_data_int/RESULTS_additional_collapses.dta", replace

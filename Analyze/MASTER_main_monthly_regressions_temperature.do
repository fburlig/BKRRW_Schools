************************************************
**** ANALYSIS: MONTHLY REGRESSIONS INCLUDING TEMPERATURE
************************************************
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
gen davis_denominator = .
gen davis_denominator2 = .
gen se_mos = .
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
foreach depvar in 0 /*7 9 10 11*/ {
foreach subsample in 0 3 6 12 13  {
foreach postctrls in ""  {
  foreach blocks in any_post_treat cumul_kwh_binary upgr_counter_all cumul_kwh {
   foreach spec in c f i m h j {
	 
	 {
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	 }
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
	  local ifs = ""
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain#prediction"
	  } 
	 
	 	 local fes = "`fes' cds_code##c.daily_t_max cds_code##c.daily_t_min cds_code##c.daily_t_mean "


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
		  gen prediction = 1
		  // this is a m:1 merge because we collapse by posttrain
		  merge m:1 cds_code year month block using "$dirpath_data_int/school_weather_MASTER_monthly.dta", keep(3)

		  
		  
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
		  qui reghdfe qkw_hour `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(cds_code month_of_sample)
		  local se_mos = _se[`blocks']
		  
		  qui reghdfe qkw_hour `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  
		  restore 
		  
		  replace yvar = "qkw_hour" in `row'
		  if ("`blocks'"=="any_post_treat") {
			replace xvar = "davis binary" in `row'
		  }
		  else if ("`blocks'"=="cumul_kwh_binary") {
			replace xvar = "reguant binary" in `row'
		  }
		  replace ylab = "Electricity consumption (kWh)" in `row'

		  
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace beta_aggregate = _b[`blocks'] in `row'
		  replace se_aggregate = _se[`blocks'] in `row'
		  replace se_mos = `se_mos' in `row'
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace davis_denominator = `davis' in `row'
		  replace davis_denominator2 = `davis2' in `row'

		  replace r2 = e(r2) in `row'
			
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

save "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", replace



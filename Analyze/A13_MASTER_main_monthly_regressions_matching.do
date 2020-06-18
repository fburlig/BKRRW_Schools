************************************************
**** ANALYSIS: MATCHING REGRESSIONS
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
gen districttype = ""
gen matchtype = ""
gen spec = .
gen beta_aggregate = .
gen se_aggregate = .
gen davis_denominator = .
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
foreach districttype in ANY EXACT OPPOSITE {
foreach matchtype in dailyavg blocks overall {
foreach depvar in qkw_hour_min_match {
local subsample  0 
local postctrls "" 
  foreach blocks in any_post_treat {
   foreach spec in c f i m h j {
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
	   local ctrls = "`ctrls' posttrain"
	  } 
	 

	  di "`row'"

		  preserve
		 
		  use "$dirpath_data_int/Matching/any_`districttype'_`matchtype'_FOR_REGRESSIONS_monthly.dta", clear
		  
		  
		  /*if ("`blocks'"=="any_post_treat") {
			egen davis = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			replace davis = -davis/(24*365)
		  }
		  else if ("`blocks'"=="upgr_counter_all") {
			egen davis = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			egen count_temp  = wtmean(upgr_counter_all) if cumul_kwh > 0, weight(numobs)
			replace davis = davis/count_temp
			replace davis = -davis/(24*365)
			drop count_temp
		  }*/
		  qui reghdfe cumul_kwh `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001)
		  gen davis = -_b[`blocks']/(24*365)
		  qui summ davis
		  local davis = r(mean)
		  
		  qui reghdfe `depvar' `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')

		  restore 
		  
		  replace yvar = "`depvar'" in `row'
		 
		  if ("`blocks'"=="any_post_treat") {
			replace xvar = "davis binary" in `row'
		  }
		  
		  if "`depvar'" == "qkw_hour_min_match" {
			replace ylab = "Energy consumption (kWh)" in `row'
		  }
		  
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace districttype = "`districttype'" in `row'
		  replace matchtype = "`matchtype'" in `row'
		  replace beta_aggregate = _b[`blocks'] in `row'
		  replace se_aggregate = _se[`blocks'] in `row'
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
gen tscore_aggregate = beta_aggregate / se_aggregate
gen pvalue_aggregate = 2*normal(-abs(tscore_aggregate))
gen stars_aggregate = "^{*}" if pvalue_aggregate < 0.1
replace stars_aggregate = "^{**}" if pvalue_aggregate < 0.05
replace stars_aggregate = "^{***}" if pvalue_aggregate < 0.01
gen ci95_lo_aggregate = beta_aggregate - 1.96*se_aggregate
gen ci95_hi_aggregate = beta_aggregate + 1.96*se_aggregate

save "$dirpath_data_int/RESULTS_monthly_matching.dta", replace

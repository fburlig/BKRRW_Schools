************************************************
**** RUNNING REGRESSIONS EVENT STUDY
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
** set up variables for regression outputs
cap drop yvar-r2
gen yvar = ""
gen ylab = ""
gen fe = ""
gen clustering = ""
gen controls = ""
gen subsample = ""
gen postctrls = ""
gen spec = .

local minlag = 4
local minlag1 = `minlag'+1
local pluslag = 3
local pluslag1 = `pluslag'+1
forvalues i = 2/`minlag1' {
  gen beta_min`i' = .
  gen se_min`i' = .
  }
forvalues i = 1/`pluslag1' { 
  gen beta_plus`i' = .
  gen se_plus`i' = .
}
gen beta_0 = .
gen se_0 = .
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
*foreach depvar in 0 4 2 8 {
foreach depvar in 4 {
foreach addfes in "" {
foreach subsample in 0 {
foreach postctrls in ""  {
   foreach spec in c f h m i j {
	 {
	 /*
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	 */
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
       local fes = "cds_code#block#month#prediction month_of_sample#prediction"
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
	  local fes = "`fes' `addfes'"
	 }

	  di "`row' `addfes'"

		  preserve
		 
		 
		  use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear

		  egen ever_treated = max(any_post_treat), by(cds_code)
		  replace ever_treated = 1 if ever_treated >0 & ever_treated !=.
				
		  gen int treat_date_prelim = dofm(ym(year, month)) if any_post_treat >0 & any_post_treat !=.
		  egen treat_date = min(treat_date_prelim), by(cds_code)	

		  gen int treat_date_prelim_ctrl = dofm(ym(year, month)) if posttrain == 1
		  egen treat_date_ctrl = min(treat_date_prelim_ctrl), by(cds_code)

		  gen treat_date_combo = .
		  replace treat_date_combo = treat_date_ctrl if ever_treated == 0
		  replace treat_date_combo = treat_date if ever_treated == 1
		  format treat_date_combo %td

		  gen int time_to_treat = dofm(ym(year, month)) - treat_date_combo
		  replace time_to_treat = ceil(time_to_treat/365)

		  gen byte treat_quarter_0 = 0
		  replace treat_quarter_0 = 1 if time_to_treat == 0 & ever_treated == 1

		  gen byte treat_quarter_0_ctrl = 0
		  replace treat_quarter_0_ctrl = 1 if time_to_treat == 0
			  
		  forvalues i = 2/`minlag' {
			  gen byte treat_min_`i' = 0
			  replace treat_min_`i' = 1 if time_to_treat == - `i' & ever_treated == 1
		  }
		  forvalues i = 1/`pluslag' {
			  gen byte treat_plus_`i' = 0
			  replace treat_plus_`i' = 1 if time_to_treat == `i' & ever_treated == 1
		  }

		  forvalues i = 2/`minlag' {
			 gen byte treat_min_`i'_ctrl = 0
			 replace treat_min_`i'_ctrl = 1 if time_to_treat == - `i'
		  }
		  forvalues i = 1/`pluslag' {
			 gen byte treat_plus_`i'_ctrl = 0
			 replace treat_plus_`i'_ctrl = 1 if time_to_treat == `i'
		  }
			 
		  * time control for all
		  gen byte treat_min_end_ctrl = 0
		  replace treat_min_end_ctrl = 1 if time_to_treat < - `minlag'

		  gen byte treat_plus_end_ctrl = 0
		  replace treat_plus_end_ctrl = 1 if time_to_treat > `pluslag'

		  * additional treatment for treated schools
		  gen byte treat_min_end = 0
		  replace treat_min_end = 1 if time_to_treat < - `minlag' & ever_treated == 1

		  gen byte treat_plus_end = 0
		  replace treat_plus_end = 1 if time_to_treat >  `pluslag' & ever_treated == 1

		  gen timelag = time_to_treat
		  sort ever_treated timelag
		  
		  egen min_timelag = min(timelag), by(cds_code)
		  egen max_timelag = max(timelag), by(cds_code)
		  
		  drop if min_timelag > -`minlag' 
		  drop if max_timelag < `pluslag'


		  reghdfe qkw_hour treat_quarter_0-treat_plus_end ///
			  `ctrls' `ifs' [fw=numobs] ///
			  , absorb(`fes') vce(cluster `clstrs') tol(0.001)
		  
		  restore 
		  
		  /*
		  if (`depvar'==0) {
		  	replace yvar = "qkw_hour" in `row'
		  }
		  else {
			replace yvar = "prediction_error`depvar'" in `row'
		  }
		  */
		  replace yvar = "qkw_hour" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  /*
		  if "`depvar'" == "prediction_error" {
			replace ylab = "Prediction error (kWh)" in `row'
		  }
		  else  {
			replace ylab = "Energy consumption (kWh)" in `row'
		  }
		  */
		  replace ylab = "Energy consumption (kWh)" in `row'
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  
			forvalues i = 1/`pluslag' {
			  replace beta_plus`i' = _b[treat_plus_`i'] in `row'
			  replace se_plus`i' = _se[treat_plus_`i'] in `row'
			}
			forvalues i = 2/`minlag'{
			 replace beta_min`i' = _b[treat_min_`i'] in `row'
			 replace se_min`i' = _se[treat_min_`i'] in `row'
			}
			replace beta_0 = _b[treat_quarter_0] in `row'
			replace se_0 = _se[treat_quarter_0] in `row'
			
			replace beta_plus`pluslag1' = _b[treat_plus_end] in `row'
			replace se_plus`pluslag1' = _se[treat_plus_end] in `row'
			
			replace beta_min`minlag1' = _b[treat_min_end] in `row'
			replace se_min`minlag1' = _se[treat_min_end] in `row'
			
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace r2 = e(r2) in `row'
			
		  local row = `row' + 1

  }
}
}
}
}

keep if yvar != ""
keep yvar - r2

forvalues i = 1/`pluslag1' {
  gen tscore_plus`i' = beta_plus`i' / se_plus`i'
  gen pvalue_plus`i' = 2*normal(-abs(tscore_plus`i'))
  gen stars_plus`i' = "^{*}" if pvalue_plus`i' < 0.1
  replace stars_plus`i' = "^{**}" if pvalue_plus`i' < 0.05
  replace stars_plus`i' = "^{***}" if pvalue_plus`i' < 0.01
  gen ci95_lo_plus`i' = beta_plus`i' - 1.96 * se_plus`i'
  gen ci95_hi_plus`i' = beta_plus`i' + 1.96 * se_plus`i'
}

forvalues i = 2/`minlag1' {
  gen tscore_min`i' = beta_min`i' / se_min`i'
  gen pvalue_min`i' = 2*normal(-abs(tscore_min`i'))
  gen stars_min`i' = "^{*}" if pvalue_min`i' < 0.1
  replace stars_min`i' = "^{**}" if pvalue_min`i' < 0.05
  replace stars_min`i' = "^{***}" if pvalue_min`i' < 0.01
  gen ci95_lo_min`i' = beta_min`i' - 1.96 * se_min`i'
  gen ci95_hi_min`i' = beta_min`i' + 1.96 * se_min`i'
}

gen tscore_0 = beta_0 / se_0
gen pvalue_0 = 2*normal(-abs(tscore_0))
gen stars_0 = "^{*}" if pvalue_0 < 0.1
replace stars_0 = "^{**}" if pvalue_0 < 0.05
replace stars_0 = "^{***}" if pvalue_0 < 0.01
gen ci95_lo_0 = beta_0 - 1.96 * se_0
gen ci95_hi_0 = beta_0 + 1.96 * se_0

save "$dirpath_data_int/RESULTS_monthly_eventstudies_yearly_BP.dta", replace

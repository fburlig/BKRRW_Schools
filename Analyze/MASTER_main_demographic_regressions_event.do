************************************************
**** ANALYSIS: SCHOOL DEMOGRAPHICS EVENT STUDIES
************************************************

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

local minlag = 8
local minlag1 = `minlag'+1
local pluslag = 8
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
foreach depvar in cahsee_math_pct_pass cahsee_math_mean_scalescore ///
   cahsee_ela_pct_pass cahsee_ela_mean_scalescore ///
   enr_total elaproficient mathproficient staff_count {
foreach addfes in "" {
foreach subsample in 0 {
foreach postctrls in "" {
   foreach spec in a b c {
	 local ctrls = ""
	 local clstrs = "cds_code"
	  if "`spec'" == "a" {
       local fes = "cds_code"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "b" {
       local fes = "cds_code year"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "c" {
       local fes = "cds_code distr#year"
	   replace spec = 3 in `row'   
      }
	  local ifs = ""
	  local fes = "`fes' `addfes'"
	 

	  di "`row' `addfes'"

		  preserve
		 
		  use "$dirpath_data_temp/monthly_by_block0_sample0.dta", clear
		  drop block prediction prediction_error qkw_hour
		  duplicates drop
		  gen cds_string = string(cds_code, "%30.0f")
		  replace cds_string = "0" + cds_string if length(cds_string) == 13
		  assert length(cds_string) == 14
		  drop cds_code
		  rename cds_string cds_code
		  merge m:1 cds_code year using "$dirpath_data/Other data/CA school info/ca_school_data.dta", nogen keep(1 3)
		  
		  gen distr = substr(cds_code, 1, 6)
		  
		  destring cds_code distr, replace
		  
		  
		  
		  egen ever_treated = max(any_post_treat), by(cds_code)
		  replace ever_treated = 1 if ever_treated >0 & ever_treated !=.
				
		  gen int treat_date_prelim = year if any_post_treat >0 & any_post_treat !=.
		  egen treat_date = min(treat_date_prelim), by(cds_code)	

		  gen int treat_date_prelim_ctrl = year if posttrain == 1
		  egen treat_date_ctrl = min(treat_date_prelim_ctrl), by(cds_code)

		  gen treat_date_combo = .
		  replace treat_date_combo = treat_date_ctrl if ever_treated == 0
		  replace treat_date_combo = treat_date if ever_treated == 1
		  format treat_date_combo %tm
		  

		  gen int treat_yr = treat_date_combo

		  gen byte treat_yr_0 = 0
		  replace treat_yr_0 = 1 if year == treat_yr & ever_treated == 1

		  gen byte treat_yr_0_ctrl = 0
		  replace treat_yr_0_ctrl = 1 if year == treat_yr
			
			
		  forvalues i = 2/`minlag' {
			  gen byte treat_min_`i' = 0
			  replace treat_min_`i' = 1 if year == treat_yr - `i' & ever_treated == 1
		  }
		  forvalues i = 1/`pluslag' {
			  gen byte treat_plus_`i' = 0
			  replace treat_plus_`i' = 1 if year == treat_yr + `i' & ever_treated == 1
		  }

		  forvalues i = 2/`minlag' {
			 gen byte treat_min_`i'_ctrl = 0
			 replace treat_min_`i'_ctrl = 1 if year == treat_yr - `i'
		  }
		  forvalues i = 1/`pluslag' {
			 gen byte treat_plus_`i'_ctrl = 0
			 replace treat_plus_`i'_ctrl = 1 if year == treat_yr + `i'
		  }
			 
		  * time control for all
		  gen byte treat_min_end_ctrl = 0
		  replace treat_min_end_ctrl = 1 if year < treat_yr - `minlag'

		  gen byte treat_plus_end_ctrl = 0
		  replace treat_plus_end_ctrl = 1 if year > treat_yr + `pluslag'

		  * additional treatment for treated schools
		  gen byte treat_min_end = 0
		  replace treat_min_end = 1 if year < treat_yr - `minlag' & ever_treated == 1

		  gen byte treat_plus_end = 0
		  replace treat_plus_end = 1 if year > treat_yr + `pluslag' & ever_treated == 1

		  gen timelag = treat_yr - year
		  sort ever_treated timelag


		  reghdfe `depvar' treat_yr_0-treat_plus_end ///
			  `ctrls' `ifs'  ///
			  , absorb(`fes') vce(cluster `clstrs') tol(0.001)
		  
		  restore 
		  
		  	replace yvar = "`depvar'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
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
			replace beta_0 = _b[treat_yr_0] in `row'
			replace se_0 = _se[treat_yr_0] in `row'
			
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

save "$dirpath_data_int/RESULTS_demographic_eventstudies.dta", replace

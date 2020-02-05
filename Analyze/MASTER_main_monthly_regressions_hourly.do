************************************************
**** RUNNING REGRESSIONS BLOCK EFFECTS
************************************************

************************************************
**** SETUP:
clear all
set more off, perm
version 12

global dirpath "S:/Fiona/Schools"

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
forvalues i = 1/24 {
  gen beta_block`i' = .
  gen se_block`i' = .
}
gen nobs = .
gen nschools = .
gen r2 = .
set obs 1000

local row = 1
foreach depvar in 0 1 2 3 4 5 6 7 8 {
foreach subsample in 0 {
foreach postctrls in "" "post" {
  foreach blocks in any_post_treat {
   foreach spec in c f i m h j {
	 {
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	  if "`spec'" == "c" {
       local ctrls = ""
       local fes = "cds_code#prediction block#prediction"
       local clstrs = "cds_code"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "f" {
       local ctrls = ""
       local fes = "cds_code#block#prediction"
       local clstrs = "cds_code"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "h" {
       local ctrls = ""
       local fes = "cds_code#block#prediction month_of_sample#prediction"
       local clstrs = "cds_code"
	   replace spec = 5 in `row'
      }
      else if "`spec'" == "i" {
       local ctrls = ""
       local fes = "cds_code#block#month#prediction"
       local clstrs = "cds_code"
	   replace spec = 3 in `row'
      }
      else if "`spec'" == "m" {
	   local ctrls = "c.month_of_sample#prediction"
	   local fes = "cds_code#block#month#prediction"
	   local clstrs = "cds_code"
	   replace spec = 4 in `row'
	  }
	  else if "`spec'" == "j" {
       local fes = "cds_code#block#month#prediction month_of_sample#prediction"
	   replace spec = 6 in `row'
      } 
	  local ifs = "if sample == `subsample'"
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain#prediction"
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
			replace any_post_treat = prediction_treat_error9
		  }
		  
		  qui reghdfe prediction_error block#c.`blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  
		  restore 
		  
		  if (`depvar'==0) {
		  	replace yvar = "qkw_hour" in `row'
		  }
		  else {
			replace yvar = "prediction_error`depvar'" in `row'
		  }
		  replace xvar = "`blocks'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  forvalues i = 0/23 {
		    local s = `i' + 1
			replace beta_block`s' = _b[`i'.block#any_post_treat] in `row'
			replace se_block`s' = _se[`i'.block#any_post_treat] in `row'
		  }
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
forvalues i = 1/24 {
  gen tscore_block`i' = beta_block`i' / se_block`i'
  gen pvalue_block`i' = 2*normal(-abs(tscore_block`i'))
  gen stars_block`i' = "^{*}" if pvalue_block`i' < 0.1
  replace stars_block`i' = "^{**}" if pvalue_block`i' < 0.05
  replace stars_block`i' = "^{***}" if pvalue_block`i' < 0.01
  gen ci95_lo_block`i' = beta_block`i' - 1.96 * se_block`i'
  gen ci95_hi_block`i' = beta_block`i' + 1.96 * se_block`i'
}

save "$dirpath_data_int/RESULTS_monthly_block.dta", replace

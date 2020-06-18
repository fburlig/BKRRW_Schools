************************************************
**** ANALYSIS: HOUR-OF-DAY-SPECIFIC ESTIMATES
************************************************

clear all
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
foreach depvar in 0 1 2 3 4 7 8 10 {
foreach subsample in 0 {
foreach postctrls in "" "post" {
  foreach blocks in any_post_treat {
   foreach spec in f i m h j {
	 {
	 if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }
	  if "`spec'" == "c" {
       local ctrls = ""
       local fes = "cds_code#prediction block"
       local clstrs = "cds_code"
	   replace spec = 1 in `row'
      }
      else if "`spec'" == "f" {
       local ctrls = ""
       local fes = "cds_code#block"
       local clstrs = "cds_code"
	   replace spec = 2 in `row'
      }
      else if "`spec'" == "h" {
       local ctrls = ""
       local fes = "cds_code#block month_of_sample"
       local clstrs = "cds_code"
	   replace spec = 5 in `row'
      }
      else if "`spec'" == "i" {
       local ctrls = ""
       local fes = "cds_code#block#month"
       local clstrs = "cds_code"
	   replace spec = 3 in `row'
      }
      else if "`spec'" == "m" {
	   local ctrls = "c.month_of_sample"
	   local fes = "cds_code#block#month"
	   local clstrs = "cds_code"
	   replace spec = 4 in `row'
	  }
	  else if "`spec'" == "j" {
       local fes = "cds_code#block#month month_of_sample"
	   replace spec = 6 in `row'
      } 
	  local ifs = "if sample == `subsample'"
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	  }

	  di "`row'"

		  preserve
		  
		  use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
		  
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

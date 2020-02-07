************************************************
**** ANALYSIS: EMPIRICAL BAYES
************************************************

use "$dirpath_data_temp/monthly_by_block10_sample0.dta", clear
merge m:1 cds_code using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", keep(3) nogenerate

sum school_id, det

local schoolmax = `r(max)'


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
gen beta_slope = .
gen se_slope = .
gen spec = .
gen nobs = .
gen cds_code = ""
gen school_id = .
gen davis_denominator = .
gen r2 = .

set obs 2500


local row = 1
forvalues i = 1/`schoolmax' {
foreach depvar in 10 {
foreach subsample in 0 {
foreach postctrls in "" {
  foreach blocks in posttrain {
   foreach spec in i {
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
	  local ifs = ""
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain"
	  } 
	 }

	  di "`row'"
	  
	  preserve
	  
	  local davis = 99999999
	  local beta_slope = 99999999
	  local se_slope = 99999999
	  
	  use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
      merge m:1 cds_code using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", keep(3) nogenerate
	  
      keep cds_code school_id cumul_kwh prediction_error block month_of_sample month posttrain

      keep if school_id == `i'
	  
	  cap reghdfe cumul_kwh posttrain `ctrls' `ifs', absorb(`fes')
	  cap local davis = _b[posttrain]
	  
      cap reghdfe prediction_error posttrain `ctrls' `ifs', absorb(`fes') vce(robust)
      cap local beta_slope = _b[posttrain]
	  cap local se_slope = _se[posttrain]
	  
	  restore
	  
	  
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace beta_slope = `beta_slope' in `row'
		  replace se_slope = `se_slope' in `row'
		  replace davis_denominator = `davis' in `row'
		  replace school_id = `i' in `row'
			
		  local row = `row' + 1
		  
}
}
}
}
}
}
drop if school_id == .
drop cds_code
merge 1:1 school_id using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", nogen

save "$dirpath_data_int/school_specific_slopes_robust.dta", replace

** fixing duplicated obs
gen flag = 0
replace flag = 1 if beta_slope[_n] == beta_slope[_n-1]

replace flag = 1 if beta_slope > 9999

replace beta_slope = . if flag == 1
replace se_slope = . if flag == 1
replace davis_denominator = . if flag == 1


** actually perform the empirical bayes analysis

ebayes beta_slope se_slope, gen(ebayes_slope)

save "$dirpath_data_int/school_specific_slopes_flagged_robust.dta", replace

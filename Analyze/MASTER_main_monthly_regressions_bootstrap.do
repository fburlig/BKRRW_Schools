************************************************
**** RUNNING BOOTSTRAP RESULTS
************************************************

* set up variables for regression outputs
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
gen r2 = .
set obs 20000

* adding bootstrap predictions
local bslist = ""
forvalues bs = 1(1)20 {
	local bslist = "`bslist' _bs`bs'"
}

local row = 1
foreach subsample in 0 3 {

	* read data
	gen bs_sample = ""
	qui foreach depvar in `bslist' {
		append using "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta"
		replace bs_sample = "`depvar'" if bs_sample==""
	}
	gegen clusterid = group(cds_code bs_sample)

	gunique cds_code
	local numschools = r(unique)

	keep yvar-r2 clusterid prediction_error cumul_kwh any_post_treat month block month_of_sample numobs

	foreach spec in c f i m h j {
		
		* same seed for all specs and samples
		set seed 137629
		
		* run regressions for a sample of 50
		forvalues bs = 1(1)50 {

		  di "`row'"		  
		  {
		  	 local ctrls = ""
			 local clstrs = "clusterid"
			  if "`spec'" == "c" {
			   local fes = "clusterid block"
			   replace spec = 1 in `row'
			  }
			  else if "`spec'" == "f" {
			   local fes = "clusterid#block"
			   replace spec = 2 in `row'
			  }
			  else if "`spec'" == "h" {
			   local fes = "clusterid#block month_of_sample"
			   replace spec = 5 in `row'   
			  }
			  else if "`spec'" == "i" {
			   local fes = "clusterid#block#month"
			   replace spec = 3 in `row'
			  }
			  else if "`spec'" == "j" {
			   local fes = "clusterid#block#month month_of_sample"
			   replace spec = 6 in `row'
			  } 
			  else if "`spec'" == "m" {
			   local ctrls = "c.month_of_sample"
			   local fes = "clusterid#block#month"
			   replace spec = 4 in `row'
			  }
			  if "`postctrls'" == "post" {
			   local ctrls = "`ctrls' c.posttrain"
			  } 
		  }
			 
		  preserve
		
		  * could weight by length of school data
		  bsample `numschools', cluster(clusterid)
		  
		  * Davis denominator
		  qui reghdfe cumul_kwh any_post_treat `ctrls' [fw=numobs], absorb(`fes') tol(0.001)
		  gen davis = -_b[any_post_treat]/(24*365)
		  
		  qui summ davis
		  local davis = r(mean)
		  
		  * Main regressions
		  qui reghdfe prediction_error any_post_treat `ctrls' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  
		  restore 
		  
		  replace yvar = "prediction_error_bs`bs'" in `row'
		  replace xvar = "davis binary" in `row'
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace beta_aggregate = _b[any_post_treat] in `row'
		  replace se_aggregate = _se[any_post_treat] in `row'
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace r2 = e(r2) in `row'
		  replace davis_denominator = `davis' in `row'
			
		  local row = `row' + 1
	  
	  }
	}
}

keep yvar - r2
keep if yvar != ""

save "$dirpath_data_int/RESULTS_monthly_bootstrap.dta", replace

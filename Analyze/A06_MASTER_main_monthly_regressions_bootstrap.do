************************************************
**** ANALYSIS: RUNNING BOOTSTRAP RESULTS
************************************************

* set up variables for regression outputs
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
gen r2 = .
set obs 20000

* read data
local subsample = 0
local bslist = ""
forvalues bs = 1(1)20 {
	local bslist = "`bslist' _bs`bs'"
}
gen bs_sample = ""
qui foreach depvar in `bslist' {
	append using "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta"
	replace bs_sample = "`depvar'" if bs_sample==""
}
gegen clusterid = group(cds_code bs_sample)
gsort clusterid

* Davis denominator
replace cumul_kwh = - cumul_kwh / (24*365)
by clusterid: egen cumul_kwh_binary = wtmean(cumul_kwh) if cumul_kwh < 0, weight(numobs)
replace cumul_kwh_binary = 0 if cumul_kwh_binary == .

keep yvar-r2 clusterid prediction_error cumul_kwh* any_post_treat posttrain month block month_of_sample numobs

* main loop
set seed 54321
gunique clusterid
local numschools = r(unique)/20
local postctrls = "post" 
local row = 1
forvalues bs = 1(1)50 {
	
	di "`row'"
	
	preserve
	bsample `numschools', cluster(clusterid)
	foreach spec in f i m h j {		  
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
	  
	    * Davis denominator
		qui reghdfe cumul_kwh_binary any_post_treat `ctrls' [fw=numobs], absorb(`fes') tol(0.001)
		local davis`spec' = _b[any_post_treat]
	  
		* Main regressions
		qui reghdfe prediction_error any_post_treat `ctrls' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		local beta`spec' = _b[any_post_treat]
		local se`spec' = _se[any_post_treat]
	  
	}
	restore 
	
	foreach spec in f i m h j {	
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
		
		replace yvar = "prediction_error_bs`bs'" in `row'
		replace xvar = "davis binary" in `row'
		replace fe = "`fes'" in `row'
		replace clustering = "`clstrs'" in `row'
		replace controls = "`ctrls'" in `row'
		replace subsample = "`subsample'" in `row'
		replace postctrls = "`postctrls'" in `row'
		replace beta_aggregate = `beta`spec'' in `row'
		replace se_aggregate = `se`spec'' in `row'
		replace nobs = e(N) in `row'
		replace nschools = e(N_clust) in `row'
		replace r2 = e(r2) in `row'
		replace davis_denominator = `davis`spec'' in `row'
		local row = `row' + 1
	}
}


keep yvar - r2
keep if yvar != ""
gen rate = beta_aggregate / davis_denominator

save "$dirpath_data_int/RESULTS_monthly_bootstrap.dta", replace

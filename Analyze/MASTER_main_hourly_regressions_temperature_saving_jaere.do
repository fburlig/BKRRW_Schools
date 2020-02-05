************************************************
**** ANALYSIS: HOURLY REGRESSIONS WITH TEMPERATURE (SAVINGS)
************************************************

use "$dirpath_data_temp/newpred_formerge_by_block.dta", clear
merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen
keep block prediction_error0 date cds_code month month_of_sample  temp_f any_post_treat cumul_kwh
	  
		  
** CREATE SUBSAMPLE VARIABLES
gen sample0 = 1

merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
bys cds_code: gen obs = _n


gen sample6 = 1
summ tot_kwh if obs == 1 & tot_kwh !=0, det
replace sample6 = 0 if tot_kwh < `r(p1)' & tot_kwh != 0
replace sample6 = 0 if tot_kwh > `r(p99)' & tot_kwh != 0

/*
gen sample7 = 1
replace sample7 = 0 if tot_kwh < `r(p5)' & tot_kwh != 0
replace sample7 = 0 if tot_kwh > `r(p95)' & tot_kwh != 0

cap drop sample10
gen sample10 = 1
summ mean_energy_use if obs == 1 & mean_energy_use !=0, det
replace sample10 = 0 if mean_energy_use < `r(p5)' & mean_energy_use != .
replace sample10 = 0 if mean_energy_use > `r(p95)' & mean_energy_use != .
*/

gen evertreated = 0
replace evertreated = 1 if tot_kwh > 0 & tot_kwh !=.
sort evertreated cds_code date block
	
	
forvalues pred = 0(1)0 {
	
	gen sample3 = 0
	by evertreated: egen p1_error = pctile(prediction_error`pred'), p(1)
	by evertreated: egen p99_error = pctile(prediction_error`pred'), p(99)
	replace sample3 = 1 if prediction_error`pred' > p1_error & prediction_error`pred' < p99_error
	drop p1_error p99_error

	gen sample13 = 0
	by evertreated: egen p2_error = pctile(prediction_error`pred'), p(2)
	by evertreated: egen p98_error = pctile(prediction_error`pred'), p(98)
	replace sample13 = 1 if prediction_error`pred' > p2_error & prediction_error`pred' < p98_error
	drop p2_error p98_error
}
	gen sample12 = sample3 * sample6
		  
keep block prediction_error0  cds_code month month_of_sample  temp_f any_post_treat cumul_kwh sample*
		  
tempfile analysisdata
save "`analysisdata'"		  
		  

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
gen se_mos = .
gen davis_denominator = .
gen davis_denominator2 = .
gen nobs = .
gen nschools = .
gen time = .
gen r2 = .
set obs 2000

local row = 1
*foreach depvar in 0 1 2 3 4 5 6 7 8 9 10 {
foreach depvar in 0 {
*foreach subsample in 0 {
foreach subsample in 0 3 6 12 13 {
foreach postctrls in "" {
*foreach postctrls in  "" "post" {
  foreach blocks in any_post_treat cumul_kwh_binary {
 * foreach blocks in  cumul_kwh_binary {
   foreach spec in c f i m h j {
	 {
	 /*if (`depvar'==0 | `depvar'==9) & ("`postctrls'"=="post") {
		continue
	 }
	 else if (`depvar'!=0 & `depvar'!=9) & ("`postctrls'"=="") {
		continue
	 }*/
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
	 local fes = "`fes' cds_code##c.temp_f"

	  di "`row'"

		  preserve
		 

		  use "`analysisdata'", clear
		  
		  keep if sample`subsample' == 1
		  drop sample*
		  

		  
		  
		  
		  if ("`depvar'"=="9") {
			replace any_post_treat = prediction_error_treat9
		  }

		  * Davis denominator
		  if ("`blocks'"=="any_post_treat") {
			qui reghdfe cumul_kwh `blocks' `ctrls' `ifs', absorb(`fes') tol(0.001)
			gen davis = -_b[`blocks']/(24*365)
			egen davis2 = mean(cumul_kwh) if cumul_kwh > 0 
			replace davis2 = -davis2/(24*365)
		  qui summ davis
		  local davis = r(mean)
		  qui summ davis2
		  local davis2 = r(mean)		  
		  }
		  
		  else if ("`blocks'"=="cumul_kwh_binary") {
		   * create additional savings variables
		   sort cds_code
		   
		   by cds_code: gen numobs = _N
		   sort prediction cds_code

		   by prediction cds_code: egen avg_savings_prelim = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
		   egen cumul_kwh_binary = mean(avg_savings_prelim), by(prediction cds_code)
		   replace cumul_kwh_binary = 0 if cumul_kwh_binary == .
		   replace cumul_kwh_binary = cumul_kwh_binary*any_post_treat
		   drop avg_savings_prelim
		   replace cumul_kwh = -cumul_kwh/(24*365)
		   replace cumul_kwh_binary = -cumul_kwh_binary/(24*365) 
		  }

		  
		  * Main regressions
		  /*
		  qui reghdfe prediction_error `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(cds_code month_of_sample)
		  local se_mos = _se[`blocks']
		  */
		  timer clear 1
		  timer on 1
		  qui reghdfe prediction_error `blocks' `ctrls' `ifs', absorb(`fes') tol(0.001) cluster(`clstrs')
		  timer off 1
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
			replace ylab = "Energy consumption (kWh)" in `row'
		  }
		  if "`depvar'" == "1" {
			replace ylab = "Prediction error (kWh), no ctrl schools - Min" in `row'
		  }
		  if "`depvar'" == "2" {
			replace ylab = "Prediction error (kWh), no ctrl schools - 1SE" in `row'
		  }
		  if "`depvar'" == "3" {
			replace ylab = "Prediction error (kWh) - Min" in `row'
		  }
		  if "`depvar'" == "4" {
			replace ylab = "Prediction error (kWh) - Baseline" in `row'
		  }
		  if "`depvar'" == "5" {
			replace ylab = "Prediction error (kWh) ctrls only - Min" in `row'
		  }
		  if "`depvar'" == "6" {
			replace ylab = "Prediction error (kWh) ctrls only - Min" in `row'
		  }
		  if "`depvar'" == "7" {
			replace ylab = "Prediction error (kWh) - blockwise Forest" in `row'
		  }
		  if "`depvar'" == "8" {
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
		  timer list 1
		  local time = `r(t1)'
		  di "TIME: `time'"
		  
		  replace fe = "`fes'" in `row'
		  replace clustering = "`clstrs'" in `row'
		  replace controls = "`ctrls'" in `row'
		  replace subsample = "`subsample'" in `row'
		  replace postctrls = "`postctrls'" in `row'
		  replace beta_aggregate = _b[`blocks'] in `row'
		  replace se_aggregate = _se[`blocks'] in `row'
		  replace nobs = e(N) in `row'
		  replace nschools = e(N_clust) in `row'
		  replace r2 = e(r2) in `row'
		  replace davis_denominator = `davis' in `row'
		  replace davis_denominator2 = `davis2' in `row'
		  replace time = `time' in `row'
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

save "$dirpath_data_int/RESULTS_hourly_withtemp_wsavings.dta", replace

gen rate = beta_aggregate / davis_denominator
gen rate2 = beta_aggregate / davis_denominator2
br yvar fe controls beta_aggregate rate*

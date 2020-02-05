************************************************
**** ANALYSIS: EFFECTS OF BONDS ON ENERGY USE
************************************************


*** grab bond data (at the district level)
import excel using "$dirpath_data_other/Demographics/Approved CA District Facilities Bonds.xlsx", sheet("Original - CA elections thr2014") firstrow clear
gen bond_yn = 0
replace bond_yn = 1 if regexm(Passed, "y")
replace bond_yn = 1 if regexm(Passed, "Y")

gen bond_date = .
replace bond_date = Electiondate if bond_yn == 1

gen bond_year = year(bond_date)
gen bond_month = month(bond_date)

gen bond_ym = ym(bond_year, bond_month)

rename Dcode dcode

keep bond_year bond_month dcode bond_ym

drop if bond_year < 2011

// keep only the first bond
egen min_bond_year = min(bond_year), by(dcode)
drop if bond_year != min_bond_year

duplicates drop

tempfile bond
save `bond'


clear

/*
local depvar 4
local subsample 0

use "$dirpath_data_temp/monthly_by_block`depvar'_sample`subsample'.dta", clear
format cds_code %30.0f
tostring cds_code, gen(cds_string) format(%30.0f)

gen dcode = substr(cds_string, 3, 5)

gen ym = ym(year, month)

merge m:1 dcode  using `bond', keep(1 3) gen(_bondmerge)

gen ever_treat_bond = .
replace ever_treat_bond = 0 if _bondmerge == 1
replace ever_treat_bond = 1 if _bondmerge == 3

gen bond_trt = 0
replace bond_trt = 1 if ever_treat_bond == 1 & ym >= bond_ym & bond_ym !=. & ym !=. 
*/





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
gen nobs = .
gen nschools = .
gen r2 = .
set obs 2000

local row = 1
foreach depvar in  4 /*7 9 10 11*/ {
foreach subsample in 0 /*3 6 12 13 */ {
foreach postctrls in ""  {
  foreach blocks in bond_trt /*upgr_counter_all*/ {
   foreach spec in c f i m h j {
	 /*
	 {
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
	  local ifs = "if tot_kwh == 0"
	  if "`postctrls'" == "post" {
	   local ctrls = "`ctrls' c.posttrain#prediction"
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
			replace any_post_treat = prediction_error_treat9
		  }
		  

		  
		  format cds_code %30.0f
          tostring cds_code, gen(cds_string) format(%30.0f)

		  gen dcode = substr(cds_string, 3, 5)

		  gen ym = ym(year, month)
	      merge m:1 dcode  using `bond', keep(1 3) gen(_bondmerge)

		  gen ever_treat_bond = .
          replace ever_treat_bond = 0 if _bondmerge == 1
          replace ever_treat_bond = 1 if _bondmerge == 3

          gen bond_trt = 0
          replace bond_trt = 1 if ever_treat_bond == 1 & ym >= bond_ym & bond_ym !=. & ym !=. 

		  
		  
		  
		  * Regressions
		  qui reghdfe qkw_hour `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(cds_code month_of_sample)
		  local se_mos = _se[`blocks']
		  
		  qui reghdfe qkw_hour `blocks' `ctrls' `ifs' [fw=numobs], absorb(`fes') tol(0.001) cluster(`clstrs')
		  
		  /* old code
		  if ("`blocks'"=="any_post_treat") {
			egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			replace davis2 = -davis2/(24*365)
		  }
		  else if ("`blocks'"=="upgr_counter_all") {
			egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			replace davis2 = -davis2/(24*365)
			egen davis2 = wtmean(cumul_kwh) if cumul_kwh > 0, weight(numobs)
			egen count_temp  = wtmean(upgr_counter_all) if cumul_kwh > 0, weight(numobs)
			replace davis2 = davis/count_temp
			replace davis2 = -davis/(24*365)
			drop count_temp
		  }
		  */
		  
		  restore 
		  
		  replace yvar = "qkw_hour" in `row'
		  replace xvar = "bond_trt" in `row'
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

save "$dirpath_data_int/RESULTS_monthly_BONDS.dta", replace



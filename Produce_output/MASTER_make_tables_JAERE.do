************************************************
**** MAKE FINAL TABLES
**** WRITTEN BY FIONA BURLIG (fiona.burlig@berkeley.edu)

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
global dirpath_results_prelim "$dirpath/Results/Preliminary"
global dirpath_results_final "$dirpath/Results/Final"
global dirpath_data_other "$dirpath/Data/Other data"
global dirpath_code "$dirpath/Data/Other data/Demographics/PSmatch code"
global dirpath_school_code "S:/Fiona/backup/Code"
set seed 12345

global sample 0

************************************************
************************************************


************************************************
*                                              *
*                   MAIN TEXT                  *
*                                              *
************************************************


************************************************
************************************************


******* TABLE: SELECTION INTO TREATMENT
{

use "$dirpath_data_temp/monthly_by_block4_sample0.dta", clear
keep cds_code
duplicates drop
merge 1:1 cds_code using "$dirpath_data_int/data_for_selection_table.dta", keep(3)

keep if _treatmerge == 3

label var qkw_hour "Hourly energy use (kWh)"
lab var enr_total "Total enrollment"
lab var API_BASE "Acad. perf. index (200-1000)"
lab var closebond_2 "Bond passed, last 2 yrs (0/1)"
lab var closebond_5 "Bond passed, last 5 yrs (0/1)"
lab var HSG "High school graduates (\%)"
lab var COL_GRAD "College graduates (\%)"
lab var pct_single_mom "Single mothers (\%)"
lab var PCT_AA "African American (\%)"
lab var PCT_AS "Asian (\%)"
lab var PCT_HI "Hispanic (\%)"
lab var PCT_WH "White (\%)"
lab var PCT_MR "2+ races (\%)"
lab var temp_f "Average temp. ($^{\circ}$ F)"


capture file close myfile
file open myfile using "$dirpath_results_final/tab_sum_stats_selection.tex", write replace

** CATEGORY EMPTY CONTROL EMPTY ANY:T  ANY:T-C EMPTY HVAC:T HVAC:T-C EMPTY LIGHT:T LIGHT:T-C
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}lccc}" _n
file write myfile "\toprule" _n
file write myfile "Characteristic & Untreated & Treated & T-U \\" _n
file write myfile "\midrule" _n
foreach var of varlist qkw_hour {

	local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
    			local mean = string(r(p),"%6.2f")
				
	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ " _n	
	
}
foreach var of varlist  year {

	local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* CONTROL
	summ `var' if evertreated_any == 0
	file write myfile " &" %4.0f (r(mean)) _tab

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %4.0f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %4.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/

	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%4.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ \midrule " _n	
	
}

foreach var of varlist enr_total API_BASE  {
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.0f (r(mean)) _tab

** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.0f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/

	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ " _n	
	
 }
 

foreach var of varlist closebond_2 closebond_5 HSG COL_GRAD pct_single_mom PCT_AA PCT_AS PCT_HI PCT_WH { 
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ " _n	
	
 
 }
 
file write myfile "\midrule " _n	

 
 qui foreach var of varlist temp_f cde_lat cde_lon{
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab
	
	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/

	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}

	file write myfile "\\ " _n	
 }
 	file write myfile "\midrule " _n	

 qui {
 tab qkw_hour if evertreated_any == 0
 local ctrln = r(N)
  tab qkw_hour if evertreated_any == 1
 local anyn = r(N)
file write myfile "Number of schools &`ctrln' & `anyn' \\" _n

 }
file write myfile "\bottomrule" _n
file write myfile "\end{tabular*}" _n
file close myfile

}


************************************************
************************************************


******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS SAVINGS (BINARY, LEVELS)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
*replace davis_denominator = davis_denominator2
*drop davis_denominator2 time
replace spec = 7 if spec == 6
keep if spec==7
*drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Treat $\times$ post" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i'
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 
	
	file write myfile "Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i'
		local beta = r(mean)
		summ davis_denominator if spec == `i'
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n	
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i'
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************




******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
*replace davis_denominator = davis_denominator2
*drop davis_denominator2 time
replace spec = 7 if spec == 6
keep if spec==7
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_hourly_withtemp_savings.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
replace xvar = "savings binary" if beta >= 0

keep if xvar == "savings binary"
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"
keep if xvar =="savings binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS SAVINGS (BINARY, LEVELS, SAMPLES)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" 

keep if subsample == "3" | subsample == "6" | subsample == "12"

local nspec 6
replace spec = spec - 1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_samples.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach s in "3" "6" "12" {
if "`s'" == "3" {
  local panel = "\emph{Panel A: Trim outlier observation}"
}
else if "`s'" == "6" {
  local panel = "\emph{Panel B: Trim outlier schools}"
}
else if "`s'" == "12" {
  local panel = "\emph{Panel C: Trim observations and schools}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n

	file write myfile "\quad Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	/*
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	*/
	file write myfile "\\ " _n
file write myfile "\quad Point estimate" 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp. Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH REGUANT SAVINGS (BINARY, LEVELS, SAMPLES)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp_savings.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
replace xvar = "savings binary" if beta >= 0

keep if xvar == "savings binary"
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"
keep if xvar =="savings binary" & yvar == "qkw_hour" 
replace spec = spec-1


keep if xvar =="savings binary" & yvar == "qkw_hour" 

keep if subsample == "3" | subsample == "6" | subsample == "12"

local nspec 6

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_reguant_samples.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach s in "3" "6" "12" {
if "`s'" == "3" {
  local panel = "\emph{Panel A: Trim outlier observation}"
}
else if "`s'" == "6" {
  local panel = "\emph{Panel B: Trim outlier schools}"
}
else if "`s'" == "12" {
  local panel = "\emph{Panel C: Trim observations and schools}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n


file write myfile "\quad Realization rate" 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp. Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



************************************************
************************************************


******* TABLE: MACHINE LEARNING RESULTS WITH DAVIS SAVINGS (BINARY, LEVELS)
{

use "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if xvar =="davis binary" & yvar == "prediction_error4" & subsample== "0"
local nspec 5
replace spec = spec-1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Treat $\times$ post" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i'
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 
	
	file write myfile "Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i'
		local beta = r(mean)
		summ davis_denominator if spec == `i'
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n	
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i'
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************


************************************************
************************************************

******* TABLE: ML RESULTS WITH DAVIS SAVINGS (BINARY, LEVELS, SAMPLES)
{

use "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if xvar =="davis binary" & yvar == "prediction_error4" 

keep if subsample == "3" | subsample == "6" | subsample == "12"

local nspec 5
replace spec=spec-1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_samples.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach s in "3" "6" "12" {
if "`s'" == "3" {
  local panel = "\emph{Panel A: Trim outlier observation}"
}
else if "`s'" == "6" {
  local panel = "\emph{Panel B: Trim outlier schools}"
}
else if "`s'" == "12" {
  local panel = "\emph{Panel C: Trim observations and schools}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n

	file write myfile "\quad Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	/*
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	*/
	file write myfile "\\ " _n

file write myfile "\quad Point estimate" 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************



******* TABLE: ML RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
*replace davis_denominator = davis_denominator2
*drop davis_denominator2 time
replace spec = 7 if spec == 6
keep if spec==7
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "prediction_error4" & subsample== "0"
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_hourly_withtemp_savings.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
replace xvar = "savings binary" if beta >= 0

keep if xvar == "savings binary"
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"
keep if xvar =="savings binary" & yvar == "prediction_error4" & subsample== "0"
local nspec 5
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}





******* TABLE: ML RESULTS WITH REGUANT SAVINGS (BINARY, LEVELS, SAMPLES)
{

use "$dirpath_data_int/RESULTS_monthly_savings.dta", clear
keep if xvar =="savings binary" & yvar == "prediction_error4" 


keep if subsample == "3" | subsample == "6" | subsample == "12"

local nspec 5

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_reguant_samples.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach s in "3" "6" "12" {
if "`s'" == "3" {
  local panel = "\emph{Panel A: Trim outlier observation}"
}
else if "`s'" == "6" {
  local panel = "\emph{Panel B: Trim outlier schools}"
}
else if "`s'" == "12" {
  local panel = "\emph{Panel C: Trim observations and schools}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n

	file write myfile "\quad Realization rate " 
 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



************************************************
************************************************


***** TABLE: HETEROGENEITY
{

use "$dirpath_data_int/MONTHLY_heterogeneity_by_characteristics.dta", clear
local nspec = 6

local label_b_cons "Constant"
local label_b_hvac_dummy "HVAC only (0/1)"
local label_b_light_dummy "Lighting only (0/1)"
local label_b_hvac_light "HVAC and Lighting (0/1)"
local label_b_API_BASE "Academic perf. index (200-1000)" 
local label_b_cde_lon "Longitude"
local label_b_cde_lat "Latitude"
local label_b_enr_total "Total enrollment"
local label_b_poverty_rate "Poverty rate"
local label_b_temp_f "Average temperature ($^{\circ}$ F)"
local label_b_mean_energy_use "Hourly energy consumption (kWh)"
local label_b_tot_kwh "Expected savings (kWh)"



capture file close myfile
file open myfile using "$dirpath_results_final/tab_heterogeneity.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\thispagestyle{empty}" _n
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
file write myfile "Variable"
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n

foreach var in "cons" "hvac_dummy" "light_dummy" "hvac_light" "cde_lon" "cde_lat" "temp_f" "enr_total" "API_BASE" "poverty_rate" "tot_kwh" {
file write myfile "`label_b_`var''"  
forvalues i = 1(1)`nspec' {
  summ b_`var' if spec == `i'
  local mean = string(r(mean), "%6.2f")
  if (r(N) == 0) {
  file write myfile "&"
  }
  else {
  file write myfile "& `mean'"
  }
  }
  file write myfile " \\ " _n
forvalues i = 1(1)`nspec' {
  summ se_`var' if spec == `i'
  local mean = string(r(mean), "%6.2f")
  if (r(N) == 0) {
  file write myfile "& "
  }
  else {
  file write myfile "& (`mean')"
  }
  }
  file write myfile "\\ "_n

  }

file write myfile "\midrule " _n 
	local lablocal: var label nobs
	file write myfile "Number of schools" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec==`i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
file write myfile "\\ " _n		
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



************************************************
************************************************


************************************************
*                                              *
*                   APPENDIX                   *
*                                              *
************************************************


******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS (BINARY, LEVELS, MULTIPLE CLUSTERING OPTIONS)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
drop if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1


capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_aggregate_regressions_2wayclus_binary.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
file write myfile "Clustering" 
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i'
	local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
}		
file write myfile "\\  School " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
		
file write myfile "\\  School, month of sample " _n
		forvalues i = 1(1)`nspec' {
			summ se_mos if spec == `i'
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & [`mean'] "
			}
		}		
		
file write myfile "\\ "_n

	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp. Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile

}

************************************************
************************************************



************************************************
************************************************

******* TABLE: OUT-OF-SAMPLE PREDICTION: ML METHODS
{

use "$dirpath_data_int/varied_ml_methods_r2_post.dta", clear


keep if posttrain == 1 & treatment_school == 0

local ntypes "1 2 3 4 7 8"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_mlmethods_r2.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\thispagestyle{empty}" _n
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
foreach i in `ntypes' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
foreach i in `ntypes'{
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "10th percentile  " 
		foreach i in `ntypes' {
			summ r2`i' , det
				local mean = string(r(p10),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
		
file write myfile "25th percentile  " 
		foreach i in `ntypes' {
			summ r2`i' , det
				local mean = string(r(p25),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
	
file write myfile "50th percentile  " 
		foreach i in `ntypes' {
			summ r2`i' , det
				local mean = string(r(p50),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
	
file write myfile "75th percentile  " 
		foreach i in `ntypes' {
			summ r2`i' , det
				local mean = string(r(p75),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
	
file write myfile "90th percentile  " 
		foreach i in `ntypes' {
			summ r2`i' , det
				local mean = string(r(p90),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
	
	
	/*
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`ntypes' {
		summ r2`i' , det
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(N)) " "
		}
	}
	
	file write myfile "\\ " _n	
	*/
	file write myfile "\midrule " _n 

*file write myfile "Method & LASSO & LASSO & LASSO & LASSO & LASSO & LASSO & RF & RF \\" _n
*file write myfile "Hour-specific model & X & X & X & X & X & X & X &  \\" _n
*file write myfile "Basic variables & X & X & X & X &  &  & X & X \\" _n
*file write myfile "Untreated schools $-i$  & &  & X & X & X & X &  &  \\" _n
*file write myfile "Tuning parameter & Min & 1SE & Min & 1SE & Min & 1SE &  &  \\" _n
file write myfile "Method & LASSO & LASSO & LASSO & LASSO & RF & RF \\" _n
file write myfile "Basic variables & X & X & X & X & X & X \\" _n
file write myfile "Hour-specific model & X & X & X & X & X &  \\" _n
file write myfile "Untreated schools $-i$  & &  & X & X &  &  \\" _n
file write myfile "Tuning parameter & Min & 1SE & Min & 1SE &  &  \\" _n

file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



******* TABLE: MATCHING RESULTS -- ANY INTERVENTION (BINARY, LEVELS)
{
use "$dirpath_data_int/RESULTS_monthly_matching.dta", clear

local nspec  5
replace spec = spec-1

gen resulttype = .
replace resulttype = 1 if districttype == "ANY" & matchtype == "dailyavg"
replace resulttype = 2 if districttype == "ANY" & matchtype == "Hours"
replace resulttype = 3 if districttype == "ANY" & matchtype == "overall"
replace resulttype = 4 if districttype == "EXACT" & matchtype == "dailyavg"
replace resulttype = 5 if districttype == "EXACT" & matchtype == "Hours"
replace resulttype = 6 if districttype == "EXACT" & matchtype == "overall"
replace resulttype = 7 if districttype == "OPPOSITE" & matchtype == "dailyavg"
replace resulttype = 8 if districttype == "OPPOSITE" & matchtype == "Hours"
replace resulttype = 9 if districttype == "OPPOSITE" & matchtype == "overall"


gen resulttype_3 = .
gen resulttype_6 = .
gen resulttype_9 = .

label var resulttype_3 "Any district"
label var resulttype_6 "Same district"
label var resulttype_9 "Opposite district"

local resulttypes = 9


capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_matching_any_binary.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\thispagestyle{empty}" _n
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
file write myfile ""
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
forvalues b = 3(3)9 {
	local lablocal: var label resulttype_`b'
	file write myfile "`lablocal'" 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec==`i' & resulttype == `b'
			local mean = string(r(mean),"%6.2f")

		if (r(N) != 0) {
			file write myfile " & `mean' "
		}
	}
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec==`i' & resulttype == `b'
			local mean = string(r(mean),"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`mean') "
		}
	}

		file write myfile "\\[1ex] " _n	
	

}
file write myfile "\quad Observations" 
forvalues i = 1(1)`nspec' {
	summ nobs if spec==`i' 
	if (r(N) != 0) {
		file write myfile " & " %10.0fc (r(mean)) " "
	}
}
file write myfile "\\ \midrule" _n		

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes\\" _n
file write myfile "Time trend & No & No & Yes & No & No\\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************


******* TABLE: MACHINE LEARNING RESULTS BY INTERVENTION TYPE (BINARY, LEVELS, MULTIPLE CLUSTERING OPTIONS)
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear

keep if xvar =="davis binary" & yvar == "prediction_error4" & subsample== "0"
local nspec 5
replace spec = spec-1


capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_aggregate_predictions_2wayclus_binary.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
file write myfile "Clustering" 
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i'
	local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
}		
file write myfile "\\  School " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
		
file write myfile "\\  School, month of sample " _n
		forvalues i = 1(1)`nspec' {
			summ se_mos if spec == `i'
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & [`mean'] "
			}
		}		
		
file write myfile "\\ "_n

	local lablocal: var label nobs
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile

}

************************************************
************************************************



******* TABLE: MACHINE LEARNING RESULTS WITH DAVIS SAVINGS (BINARY, LEVELS, ALL ML MODELS)
{

use "$dirpath_data_int/RESULTS_monthly_allml_models.dta", clear
keep if xvar =="davis binary"  & subsample== "0" & spec == 6

drop if strpos(yvar, "qkw_hour") & strpos(controls, "c.")
drop if strpos(yvar, "prediction_error") & controls == ""

local predtypes "1 2 3 4 7 8"

capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_aggregate_predictions_binary_davis_allml.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
foreach i in `predtypes' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
local count = 1
foreach i in `predtypes' {
	file write myfile " & (`count') "
	local count = `count' + 1
}
file write myfile " \\ \midrule " _n
file write myfile "Treat $\times$ post" 
foreach i in `predtypes' {
	summ beta_aggregate if yvar == "prediction_error`i'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
foreach i in `predtypes' {
			summ se_aggregate if yvar == "prediction_error`i'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
/*
		file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`pred' {
		summ nobs if yvar == "prediction_error`i'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
*/
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 
	
	file write myfile "Realization rate " 
foreach i in `predtypes' {
		summ beta_aggregate if yvar == "prediction_error`i'"
		local beta = r(mean)
		summ davis_denominator if yvar == "prediction_error`i'"
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n		
	foreach i in `predtypes' {
		summ se_aggregate if yvar == "prediction_error`i'"
		local se_beta = r(mean)
		summ davis_denominator if yvar == "prediction_error`i'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 

file write myfile "Method & LASSO & LASSO & LASSO & LASSO & RF & RF \\" _n
file write myfile "Hour-specific model & X & X & X & X &  X &  \\" _n
file write myfile "Basic variables & X & X & X & X & X & X \\" _n
file write myfile "Untreated schools $-i$  & &  & X & X &  &  \\" _n
file write myfile "Tuning parameter & Min & 1SE & Min & 1SE &  &  \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************

/*
******* TABLE: SELECTION INTO TREATMENT
{

use "$dirpath_data_temp/monthly_by_block4_sample0.dta", clear
keep cds_code
duplicates drop
merge 1:1 cds_code using "$dirpath_data_int/data_for_selection_table.dta", keep(3)

keep if _treatmerge == 3

label var qkw_hour "Hourly energy use (kWh)"
lab var enr_total "Total enrollment"
lab var API_BASE "Acad. perf. index (200-1000)"
lab var closebond_2 "Bond passed, last 2 yrs (0/1)"
lab var closebond_5 "Bond passed, last 5 yrs (0/1)"
lab var HSG "High school graduates (\%)"
lab var COL_GRAD "College graduates (\%)"
lab var pct_single_mom "Single mothers (\%)"
lab var PCT_AA "African American (\%)"
lab var PCT_AS "Asian (\%)"
lab var PCT_HI "Hispanic (\%)"
lab var PCT_WH "White (\%)"
lab var PCT_MR "2+ races (\%)"
lab var temp_f "Average temp. ($^{\circ}$ F)"


capture file close myfile
file open myfile using "$dirpath_results_final/tab_sum_stats_selection.tex", write replace

** CATEGORY EMPTY CONTROL EMPTY ANY:T  ANY:T-C EMPTY HVAC:T HVAC:T-C EMPTY LIGHT:T LIGHT:T-C
file write myfile "\begin{tabular}{lcccclcclccl}" _n
file write myfile "\toprule" _n
file write myfile "& Untreated& & \multicolumn{2}{c}{Any intervention} & & \multicolumn{2}{c}{HVAC interventions} & & \multicolumn{2}{c}{Lighting interventions} \\" _n
file write myfile "\cline{4-5} \cline{7-8} \cline{10-11}" _n
file write myfile "Characteristic && & Treated & T-U && Treated & T-U&&Treated & T-U\\" _n
file write myfile "\midrule" _n
foreach var of varlist qkw_hour {

	local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab
	file write myfile "&" _tab
	
	

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile "&" _tab
	

	** HVAC
	summ `var' if evertreated_hvac_pure == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_hvac_pure)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	file write myfile "&" _tab
	
	** LIGHT
	summ `var' if evertreated_light_pure == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_light_pure)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	**************** STD DEVIATIONS
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab
		file write myfile " &" _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
    			local mean = string(r(p),"%6.2f")
				
	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
    file write myfile "&" _tab
    *** HVAC
	
	summ `var' if evertreated_hvac_pure == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_hvac_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}		
	file write myfile " &" _tab

	*** LIGHT
	summ `var' if evertreated_light_pure == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab
	
	ttest `var', by(evertreated_light_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "\\ " _n	
	
}
foreach var of varlist  year {

	local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* CONTROL
	summ `var' if evertreated_any == 0
	file write myfile " &" %4.0f (r(mean)) _tab
	file write myfile "&" _tab
	
	

	** ANY
	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %4.0f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %4.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile "&" _tab
	

	** HVAC
	summ `var' if evertreated_hvac_pure == 1
	file write myfile " &" %4.0f (r(mean)) _tab
	ttest `var', by(evertreated_hvac_pure)
	file write myfile " &" %4.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	file write myfile "&" _tab
	
	** LIGHT
	summ `var' if evertreated_light_pure == 1
	file write myfile " &" %4.0f (r(mean)) _tab
	ttest `var', by(evertreated_light_pure)
	file write myfile " &" %4.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab
		file write myfile " &" _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%4.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "&" _tab
    *** HVAC
	
	summ `var' if evertreated_hvac_pure == 1, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_hvac_pure)
			local mean = string(r(p),"%4.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
		file write myfile " &" _tab

	*** LIGHT
	summ `var' if evertreated_light_pure == 1, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab
	
	ttest `var', by(evertreated_light_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	
	file write myfile "\\ \midrule " _n	
	
}

foreach var of varlist enr_total API_BASE  {
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.0f (r(mean)) _tab
	file write myfile "&" _tab
	
	

	** ANY
** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.0f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile "&" _tab
	

	** HVAC
	summ `var' if evertreated_hvac_pure == 1
	file write myfile " &" %6.0f (r(mean)) _tab
	ttest `var', by(evertreated_hvac_pure)
	file write myfile " &" %6.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	file write myfile "&" _tab
	
	** LIGHT
	summ `var' if evertreated_light_pure == 1
	file write myfile " &" %6.0f (r(mean)) _tab
	ttest `var', by(evertreated_light_pure)
	file write myfile " &" %6.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab
		file write myfile " &" _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "&" _tab
    *** HVAC
	
	summ `var' if evertreated_hvac_pure == 1, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_hvac_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
		file write myfile " &" _tab

	*** LIGHT
	summ `var' if evertreated_light_pure == 1, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab
	
	ttest `var', by(evertreated_light_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "\\ " _n	
	
 
 }
 

 
 
 
 
 

foreach var of varlist closebond_2 closebond_5 HSG COL_GRAD pct_single_mom PCT_AA PCT_AS PCT_HI PCT_WH { 
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab
	file write myfile "&" _tab
	
	

	** ANY
** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile "&" _tab
	

	** HVAC
	summ `var' if evertreated_hvac_pure == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_hvac_pure)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	file write myfile "&" _tab
	
	** LIGHT
	summ `var' if evertreated_light_pure == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_light_pure)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab
		file write myfile " &" _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "&" _tab
    *** HVAC
	
	summ `var' if evertreated_hvac_pure == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_hvac_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
		file write myfile " &" _tab

	*** LIGHT
	summ `var' if evertreated_light_pure == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab
	
	ttest `var', by(evertreated_light_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "\\ " _n	
	
 
 }
 
 
 
 
 
 
 

 

file write myfile "\midrule " _n	

 
 qui foreach var of varlist temp_f cde_lat cde_lon{
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab
	file write myfile "&" _tab
	
	

	** ANY
	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile "&" _tab
	

	** HVAC
	summ `var' if evertreated_hvac_pure == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_hvac_pure)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	file write myfile "&" _tab
	
	** LIGHT
	summ `var' if evertreated_light_pure == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_light_pure)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}*/
	
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab
		file write myfile " &" _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	file write myfile "&" _tab
    *** HVAC
	
	summ `var' if evertreated_hvac_pure == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_hvac_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
		file write myfile " &" _tab

	*** LIGHT
	summ `var' if evertreated_light_pure == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab
	
	ttest `var', by(evertreated_light_pure)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] & " _tab
	}
	else {
	file write myfile " [`mean'] & " _tab
	}
	
	file write myfile "\\ " _n	
 }
 	file write myfile "\midrule " _n	

 qui {
 tab qkw_hour if evertreated_any == 0
 local ctrln = r(N)
  tab qkw_hour if evertreated_any == 1
 local anyn = r(N)
  tab qkw_hour if evertreated_hvac_pure == 1
 local hvacn = r(N)
   tab qkw_hour if evertreated_light_pure == 1
 local lightn = r(N)
file write myfile "Number of schools &`ctrln' && `anyn' &  && `hvacn' & &&`lightn' \\" _n

 }
file write myfile "\bottomrule" _n
file write myfile "\end{tabular}" _n
file close myfile

}


************************************************
************************************************
*/
/*
******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS (TRIM 0, 1/99, 2/98) [BINARY, LEVELS]
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if yvar == "qkw_hour" & xvar == "davis binary" & spec == 6

replace spec = .
replace spec = 1 if subsample == "0"
replace spec = 2 if subsample == "3"
replace spec = 3 if subsample == "13"
local nspec 3

capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_aggregate_regressions_samples_levels_binary.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Treat $\times$ post" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i' 
	local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i' 
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n

	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i' 
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 
	
	file write myfile "Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' 
		local beta = r(mean)
		summ davis_denominator  if spec == `i' 
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n		
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	file write myfile "\\ " _n
	file write myfile "\midrule " _n 	
	

file write myfile "Trimming        &  & & \\" _n
file write myfile "\quad Dependent variable (1, 99) & & X & \\" _n
file write myfile "\quad Dependent variable (2, 98) & &  &X \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile

}

************************************************
************************************************
*/

/*
******* TABLE: MACHINE LEARNING RESULTS (TRIM 0, 1/99, 2/98) [BINARY, LEVELS]
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if yvar == "prediction_error4" & xvar == "davis binary" & spec == 5

replace spec = .
replace spec = 1 if subsample == "0"
replace spec = 2 if subsample == "3"
replace spec = 3 if subsample == "13"
local nspec 3

capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_aggregate_predictions_samples_levels_binary.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Treat $\times$ post" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i' 
	local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i' 
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n

	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i' 
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 
	
	file write myfile "Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' 
		local beta = r(mean)
		summ davis_denominator  if spec == `i' 
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 	
	

file write myfile "Trimming        &  & & \\" _n
file write myfile "\quad Dependent variable (1, 99) & & X & \\" _n
file write myfile "\quad Dependent variable (2, 98) & &  &X \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile

}

************************************************
************************************************
*/

/*
******* TABLE: REALIZATION RATES -- ALTERNATIVE ESTIMATION PROCEDURES 
{
*** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
append using "$dirpath_data_int/RESULTS_monthly_tech.dta"
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"
append using "$dirpath_data_int/RESULTS_monthly_savings_tech.dta"

keep if subsample == "0" | subsample == "6" 
keep if xvar == "savings binary" | xvar == "savings continuous" | xvar == "davis binary" | xvar == "davis continuous (counter)"

keep if yvar == "prediction_error4"

keep if spec == 5

gen rr_any = .
replace rr_any = beta_aggregate if xvar == "savings continuous" | xvar == "savings binary"
replace rr_any = beta_aggregate / davis_denominator if xvar == "davis binary" | xvar == "davis continuous (counter)"
replace rr_any = -rr_any if rr_any <0


gen se_rr_any = .
replace se_rr_any = se_aggregate if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_any = se_aggregate / davis_denominator if xvar == "davis binary" | xvar == "davis continuous (counter)"
replace se_rr_any = -se_rr_any if se_rr_any <0


replace rr_hvac = beta_aggregate_hvac if xvar == "savings continuous" | xvar == "savings binary"
replace rr_light = beta_aggregate_light if xvar == "savings continuous" | xvar == "savings binary"
replace rr_other = beta_aggregate_other if xvar == "savings continuous" | xvar == "savings binary"

gen se_rr_hvac = .
replace se_rr_hvac = se_aggregate_hvac if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_hvac = se_aggregate_hvac / davis_hvac if xvar == "davis continuous (counter)" | xvar == "davis binary"
replace se_rr_hvac = -se_rr_hvac if se_rr_hvac < 0

gen se_rr_light = .
replace se_rr_light = se_aggregate_light if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_light = se_aggregate_light / davis_light if xvar == "davis continuous (counter)" | xvar == "davis binary"
replace se_rr_light = -se_rr_light if se_rr_light < 0

gen se_rr_other = .
replace se_rr_other = se_aggregate_other if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_other = se_aggregate_other / davis_other if xvar == "davis continuous (counter)" | xvar == "davis binary"
replace se_rr_other = -se_rr_other if se_rr_other < 0
}
*** MAKE TABLE
{

label var nobs "Observations"

local label_any = "Any intervention"
local label_hvac = "HVAC interventions"
local label_light = "Lighting interventions"
local label_other = "Other interventions"

local ntypes=6
cap drop column
gen column = .

replace column = 1 if subsample == "0" & xvar == "davis binary"
replace column = 2 if subsample == "6" & xvar == "davis binary"
replace column = 3 if subsample == "0" & xvar == "davis continuous (counter)"
replace column = 4 if subsample == "0" & xvar == "savings binary"
replace column = 5 if subsample == "6" & xvar == "savings binary"
replace column = 6 if subsample == "0" & xvar == "savings continuous"



capture file close myfile
file open myfile using "$dirpath_results_final/tab_savings_alt_mlonly_nf.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\thispagestyle{empty}" _n
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`ntypes' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`ntypes' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Any intervention  " _n
	foreach vv in  "prediction_error" {
		forvalues i = 1(1)`ntypes' {
			summ rr_any if column==`i' 
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
		
		forvalues i = 1(1)`ntypes' {
			summ se_rr_any if column==`i' 
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
		file write myfile "\\[1ex] " _n	
		
	}
	/*
	local lablocal: var label nobs
	file write myfile "\quad `lablocal'" 
	forvalues i = 1(1)`ntypes' {
		summ nobs if type==`i' & reg_run == "any"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	
	file write myfile "\\ " _n		
	*/
	file write myfile "\midrule " _n 
	
foreach v in "hvac" "light" "other"{
file write myfile "`label_`v''  " _n
	foreach vv in  "prediction_error" {
		forvalues i = 1(1)`ntypes' {
			summ rr_`v' if column == `i'
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
		
		forvalues i = 1(1)`ntypes' {
			summ se_rr_`v' if column == `i'
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
		file write myfile "\\[1ex] " _n	
		
	}
	
	local lablocal: var label nobs
	if "`v'" == "other" {
	file write myfile "\quad `lablocal'" 
	forvalues i = 1(1)`ntypes' {
		summ nobs  if column==`i'  
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n	
	file write myfile "\midrule " _n 
	}
}
file write myfile "Savings regression         &  &  & & X & X & X\\" _n
file write myfile "Expected savings trim & & X&  &  & X &  \\" _n
file write myfile "Time-varying treatment & & & X &  & & X \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}
}
*/
************************************************
************************************************

/*
******* TABLE: MACHINE LEARNING RESULTS (MEDIAN SPLIT)
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
append using "$dirpath_data_int/RESULTS_monthly_medians.dta"

keep if yvar == "prediction_error4"  & subsample == "0" & spec == 5

gen rr_0 = beta_aggregate / davis_denominator
gen se_0 = -(se_aggregate / davis_denominator)

drop if strpos(xvar, "counter")


replace spec = .
replace spec = 1 if xvar == "davis binary"
replace spec = 2 if xvar == "kwh_quant"
replace spec = 3 if xvar == "sav_quant"
local nspec 3

capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_aggregate_predictions_medians.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile "\\ \midrule" _n

file write myfile "Overall" 
forvalues i = 1(1)`nspec' {
	summ rr_0 if spec == `i' 
	local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
	else {
	    file write myfile " & "
	}
}	
	
file write myfile "\\" _n
		forvalues i = 1(1)`nspec' {
			summ se_0 if spec == `i' 
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
			else {
				file write myfile " & "
			}			
}
file write myfile "\\[1ex] " _n	

file write myfile "Below median" 
forvalues i = 1(1)`nspec' {
	summ rr_1 if spec == `i' 
	local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
	else {
	    file write myfile " & "
	}
}	
	
file write myfile "\\" _n
		forvalues i = 1(1)`nspec' {
			summ se_1 if spec == `i' 
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
			else {
				file write myfile " & "
			}
}
file write myfile "\\[1ex] " _n	

file write myfile "Above median " _n
		forvalues i = 1(1)`nspec' {
			summ rr_2 if spec == `i' 
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
			else {
				file write myfile " & "
			}		
}
file write myfile "\\ "_n
		forvalues i = 1(1)`nspec' {
			summ se_2 if spec == `i' 
		    local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
			else {
				file write myfile " & "
			}		
}

		
file write myfile "\\[1ex] " _n	



	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i' 
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
			}
			else {
				file write myfile " & "
			}		

}
	
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 	
	

file write myfile "Median        &  & & \\" _n
file write myfile "\quad Absolute savings & & X & \\" _n
file write myfile "\quad Relative savings & &  &X \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile

}
*/


/*
******* TABLE: MACHINE LEARNING RESULTS (POOLED VS. PRE-TRAIN VS. POST-TRAIN) -- ANY ONLY [BINARY, LEVELS]
{
use  "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if yvar == "prediction_error4" | yvar == "prediction_error9" | yvar == "prediction_error10" | yvar == "prediction_error11"
keep if xvar == "davis binary"

foreach pred in 4 10 11{
drop if yvar == "prediction_error`pred'" & postctrls == ""
}

drop if yvar == "prediction_error9" & postctrls == "post"
label var nobs "Observations"

* Baseline regression table
local nspec=6
keep if subsample == "$sample"


capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_pred_prepost_any_levels_binary.tex", write replace	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile "c"
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n


foreach treattype in "any" {

local lablocal: var label beta_aggregate
file write myfile "Trained on pre" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if yvar=="prediction_error4" & spec==`i'
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean'"
	}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
	summ se_aggregate if yvar=="prediction_error4" & spec==`i'
		local mean = string(r(mean),"%6.2f")

	if (r(N) != 0) {
		file write myfile " & (`mean') "
	}	
}
file write myfile "\\ " _n	
file write myfile "Realization rate " 
forvalues i = 1(1)`nspec' {
		summ beta_aggregate if yvar=="prediction_error4" & spec==`i' 
		local beta = r(mean)
		summ davis_denominator if yvar=="prediction_error4" & spec==`i' 
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
		summ se_aggregate if yvar=="prediction_error4" & spec==`i' 
		local se_beta = r(mean)
		summ davis_denominator if yvar=="prediction_error4" & spec==`i' 
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
}
file write myfile "\\ " _n		
local lablocal: var label nobs
file write myfile "\quad `lablocal'" 
forvalues i = 1(1)`nspec' {
	summ nobs if yvar=="prediction_error4" & spec==`i' 
	if (r(N) != 0) {
		file write myfile " & " %10.0fc (r(mean)) " "
	}
}
file write myfile "\\ \midrule"_n

local lablocal: var label beta_aggregate
file write myfile "Trained on post" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if yvar=="prediction_error10" & spec==`i' 
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
	summ se_aggregate if yvar=="prediction_error10" & spec==`i' 
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & (`mean') "
	}	
}
file write myfile "\\ " _n	
file write myfile "Realization rate " 
forvalues i = 1(1)`nspec' {
		summ beta_aggregate if yvar=="prediction_error10" & spec==`i' 
		local beta = r(mean)
		summ davis_denominator if yvar=="prediction_error10" & spec==`i' 
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
		summ se_aggregate if yvar=="prediction_error10" & spec==`i' 
		local se_beta = r(mean)
		summ davis_denominator if yvar=="prediction_error10" & spec==`i' 
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
}
file write myfile "\\ " _n	
local lablocal: var label nobs
file write myfile "\quad `lablocal'" 
forvalues i = 1(1)`nspec' {
	summ nobs if yvar=="prediction_error10" & spec==`i' 
	if (r(N) != 0) {
		file write myfile " & " %10.0fc (r(mean)) " "
	}
}
file write myfile "\\ \midrule"_n
local lablocal: var label beta_aggregate
file write myfile "Pooled" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if yvar=="prediction_error11" & spec==`i' 
		local mean = string(r(mean),"%6.2f")

	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
	summ se_aggregate if yvar=="prediction_error11" & spec==`i' 
		local mean = string(r(mean),"%6.2f")

	if (r(N) != 0) {
		file write myfile " & (`mean') "
	}	
}
file write myfile "\\ " _n	
file write myfile "Realization rate " 
forvalues i = 1(1)`nspec' {
		summ beta_aggregate if yvar=="prediction_error11" & spec==`i'
		local beta = r(mean)
		summ davis_denominator if yvar=="prediction_error11" & spec==`i' 
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
		summ se_aggregate if yvar=="prediction_error11" & spec==`i'
		local se_beta = r(mean)
		summ davis_denominator if yvar=="prediction_error11" & spec==`i' 
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
}
file write myfile "\\ " _n	
local lablocal: var label nobs
file write myfile "\quad `lablocal'" 
forvalues i = 1(1)`nspec' {
	summ nobs if yvar=="prediction_error11" & spec==`i' 
	if (r(N) != 0) {
		file write myfile " & " %10.0fc (r(mean)) " "
	}
}
  file write myfile "\\ \midrule" _n
}
local lablocal: var label beta_aggregate
file write myfile "Double LASSO" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if yvar=="prediction_error9" & spec==`i' 
		local mean = string(r(mean),"%6.2f")

	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
	summ se_aggregate if yvar=="prediction_error9" & spec==`i' 
		local mean = string(r(mean),"%6.2f")

	if (r(N) != 0) {
		file write myfile " & (`mean') "
	}	
}
file write myfile "\\ " _n	
file write myfile "Realization rate " 
forvalues i = 1(1)`nspec' {
		summ beta_aggregate if yvar=="prediction_error9" & spec==`i' 
		local beta = r(mean)
		summ davis_denominator if yvar=="prediction_error9" & spec==`i' 
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
}
file write myfile "\\ " _n	
forvalues i = 1(1)`nspec' {
		summ se_aggregate if yvar=="prediction_error9" & spec==`i' 
		local se_beta = r(mean)
		summ davis_denominator if yvar=="prediction_error9" & spec==`i' 
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
}
file write myfile "\\ " _n	
local lablocal: var label nobs
file write myfile "\quad `lablocal'" 
forvalues i = 1(1)`nspec' {
	summ nobs if yvar=="prediction_error9" & spec==`i' 
	if (r(N) != 0) {
		file write myfile " & " %10.0fc (r(mean)) " "
	}
}
  file write myfile "\\ \midrule" _n

file write myfile "School FE, Hour FE   & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour FE       & No & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & No & Yes & Yes & No & Yes\\" _n
file write myfile "Time trend & No & No & No & Yes & No & No\\" _n
file write myfile "Month of Sample FE & No & No & No & No & Yes & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************
*/


/*
******* TABLE: REALIZATION RATES -- ALTERNATIVE ESTIMATION PROCEDURES [REGRESSION ONLY - NEW FLOW]

{
*** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
append using "$dirpath_data_int/RESULTS_monthly_tech.dta"
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"
append using "$dirpath_data_int/RESULTS_monthly_savings_tech.dta"

keep if subsample == "0" | subsample == "6" 
keep if xvar == "savings binary" | xvar == "savings continuous" | xvar == "davis binary" | xvar == "davis continuous (counter)"

keep if yvar == "qkw_hour"

keep if spec == 5

gen rr_any = .
replace rr_any = beta_aggregate if xvar == "savings continuous" | xvar == "savings binary"
replace rr_any = beta_aggregate / davis_denominator if xvar == "davis binary" | xvar == "davis continuous (counter)"
replace rr_any = -rr_any if rr_any <0


gen se_rr_any = .
replace se_rr_any = se_aggregate if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_any = se_aggregate / davis_denominator if xvar == "davis binary" | xvar == "davis continuous (counter)"
replace se_rr_any = -se_rr_any if se_rr_any <0


replace rr_hvac = beta_aggregate_hvac if xvar == "savings continuous" | xvar == "savings binary"
replace rr_light = beta_aggregate_light if xvar == "savings continuous" | xvar == "savings binary"
replace rr_other = beta_aggregate_other if xvar == "savings continuous" | xvar == "savings binary"

gen se_rr_hvac = .
replace se_rr_hvac = se_aggregate_hvac if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_hvac = se_aggregate_hvac / davis_hvac if xvar == "davis continuous (counter)" | xvar == "davis binary"
replace se_rr_hvac = -se_rr_hvac if se_rr_hvac < 0

gen se_rr_light = .
replace se_rr_light = se_aggregate_light if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_light = se_aggregate_light / davis_light if xvar == "davis continuous (counter)" | xvar == "davis binary"
replace se_rr_light = -se_rr_light if se_rr_light < 0

gen se_rr_other = .
replace se_rr_other = se_aggregate_other if xvar == "savings continuous" | xvar == "savings binary"
replace se_rr_other = se_aggregate_other / davis_other if xvar == "davis continuous (counter)" | xvar == "davis binary"
replace se_rr_other = -se_rr_other if se_rr_other < 0
}
*** MAKE TABLE
{

label var nobs "Observations"

local label_any = "Any intervention"
local label_hvac = "HVAC interventions"
local label_light = "Lighting interventions"
local label_other = "Other interventions"

local ntypes=6
cap drop column
gen column = .

replace column = 1 if subsample == "0" & xvar == "davis binary"
replace column = 2 if subsample == "6" & xvar == "davis binary"
replace column = 3 if subsample == "0" & xvar == "davis continuous (counter)"
replace column = 4 if subsample == "0" & xvar == "savings binary"
replace column = 5 if subsample == "6" & xvar == "savings binary"
replace column = 6 if subsample == "0" & xvar == "savings continuous"



capture file close myfile
file open myfile using "$dirpath_results_final/Appendix/tab_savings_alt_regonly_nf.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\thispagestyle{empty}" _n
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`ntypes' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`ntypes' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Any intervention  " _n
	foreach vv in  "prediction_error" {
		forvalues i = 1(1)`ntypes' {
			summ rr_any if column==`i' 
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
		
		forvalues i = 1(1)`ntypes' {
			summ se_rr_any if column==`i' 
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
		file write myfile "\\[1ex] " _n	
		
	}
	file write myfile "\midrule " _n 
	
foreach v in "hvac" "light" "other"{
file write myfile "`label_`v''  " _n
	foreach vv in  "prediction_error" {
		forvalues i = 1(1)`ntypes' {
			summ rr_`v' if column == `i'
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & `mean' "
			}
		}
		file write myfile "\\ " _n
		
		forvalues i = 1(1)`ntypes' {
			summ se_rr_`v' if column == `i'
				local mean = string(r(mean),"%6.2f")

			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
		file write myfile "\\[1ex] " _n	
		
	}
	
	local lablocal: var label nobs
	if "`v'" == "other" {
	file write myfile "\quad `lablocal'" 
	forvalues i = 1(1)`ntypes' {
		summ nobs  if column==`i'  
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n	
	file write myfile "\midrule " _n 
	}
}
file write myfile "Savings regression         &  &  & & X & X & X\\" _n
file write myfile "Expected savings trim & & X&  &  & X &  \\" _n
file write myfile "Time-varying treatment & & & X &  & & X \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}
}
************************************************
************************************************
*/


************************************************
************************************************
****************** REVISION UPDATES
************************************************
************************************************





******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS SAVINGS (BONDS)
{
use "$dirpath_data_int/RESULTS_monthly_DONUTS.dta", clear
*keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 5
replace spec = spec-1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_bonds.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n
file write myfile "Bond $\times$ post" 
forvalues i = 1(1)`nspec' {
	summ beta_aggregate if spec == `i'
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	file write myfile "\midrule " _n 
	

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

************************************************
************************************************





******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (DONUTS)
{
use "$dirpath_data_int/RESULTS_monthly_DONUTS.dta", clear
keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_monthly_savings_DONUTS.dta", clear
keep if xvar =="savings binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

keep if spec == 5

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_DONUTS.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if donuts == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & Yes & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "Month of Sample FE & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "Dropped months & 1 & 2 & 3 & 4 & 5 & 6 \\" _n

file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}




******* TABLE: ML RESULTS WITH DAVIS + REGUANT SAVINGS (DONUTS)
{
use "$dirpath_data_int/RESULTS_monthly_DONUTS.dta", clear
keep if xvar =="davis binary" & yvar == "prediction_error4" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_monthly_savings_DONUTS.dta", clear
keep if xvar =="savings binary" & yvar == "prediction_error4" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

keep if spec == 5

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_DONUTS.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if donuts == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if donuts == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & Yes & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "Month of Sample FE & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "Dropped months & 1 & 2 & 3 & 4 & 5 & 6 \\" _n

file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}





******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (CONTINUOUS, LEVELS)
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if xvar =="davis continuous (counter)" & yvar == "qkw_hour" & subsample== "0"
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_monthly_savings.dta", clear
keep if xvar =="savings continuous" & yvar == "qkw_hour" & subsample== "0"
local nspec 5
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_continuous_davis_reguant.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}






******* TABLE: ML RESULTS WITH DAVIS + REGUANT SAVINGS (CONTINUOUS, LEVELS)
{
use "$dirpath_data_int/RESULTS_monthly.dta", clear
keep if xvar =="davis continuous (counter)" & yvar == "prediction_error4" & subsample== "0"
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_monthly_savings.dta", clear
keep if xvar =="savings continuous" & yvar == "prediction_error4" & subsample== "0"
local nspec 5
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_continuous_davis_reguant.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}











******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (MONTHLY TEMPERATURE)
{
use "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
keep if xvar == "reguant binary"
replace xvar = "savings binary" if xvar == "reguant binary"
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"
keep if xvar =="savings binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_monthlyt.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}




******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS SAVINGS (BINARY, LEVELS, SAMPLES, MONTHLY TEMPERATURE)
{
use "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" 

keep if subsample == "3" | subsample == "6" | subsample == "12"

local nspec 6
replace spec = spec - 1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_samples_monthlyt.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach s in "3" "6" "12" {
if "`s'" == "3" {
  local panel = "\emph{Panel A: Trim outlier observation}"
}
else if "`s'" == "6" {
  local panel = "\emph{Panel B: Trim outlier schools}"
}
else if "`s'" == "12" {
  local panel = "\emph{Panel C: Trim observations and schools}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n

	file write myfile "\quad Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	/*
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	*/
	file write myfile "\\ " _n
file write myfile "\quad Point estimate" 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp. Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}









******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS, HOURLY EVERYTHING)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
*replace davis_denominator = davis_denominator2
*drop davis_denominator2 time
replace spec = 7 if spec == 6
keep if spec==7
keep if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta"
keep if xvar =="davis binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use "$dirpath_data_int/RESULTS_hourly_withtemp_savings.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
replace xvar = "savings binary" if beta >= 0

keep if xvar == "savings binary"
keep if strpos(fe, "##c.temp")
append using "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta"
replace xvar = "savings binary" if xvar == "reguant binary"
keep if xvar =="savings binary" & yvar == "qkw_hour" & subsample== "0"
local nspec 6
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_allhourly.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes & Yes \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes & Yes \\" _n
file write myfile "Time trend & No & No & Yes & No & No & No \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes & Yes\\" _n
file write myfile "Temp Ctrl & No & No & No & No & No & Yes\\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}






******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS, HOURLY EVERYTHING)
{
use "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta", clear
keep if xvar =="davis binary" & yvar == "prediction_error4" & subsample== "0"
replace spec = spec-1
gen estimator = "davis"
tempfile davis
save "`davis'"

use  "$dirpath_data_int/RESULTS_hourly_NOtemp_wsavings.dta", clear
replace xvar = "savings binary" if xvar == "reguant binary"
keep if xvar =="savings binary" & yvar == "prediction_error4" & subsample== "0"
local nspec 5
replace spec = spec-1
gen estimator = "reguant"

append using "`davis'"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_allhourly.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}








******* TABLE: SELECTION INTO TREATMENT (COASTAL)
{

use "$dirpath_data_temp/monthly_by_block4_sample0.dta", clear
keep cds_code
duplicates drop
merge 1:1 cds_code using "$dirpath_data_int/data_for_selection_table.dta", keep(3)
merge 1:1 cds_code using "$dirpath_data_temp/cds_coastal.dta", keep(1 3) nogen
keep if _treatmerge == 3

label var qkw_hour "Hourly energy use (kWh)"
lab var enr_total "Total enrollment"
lab var API_BASE "Acad. perf. index (200-1000)"
lab var closebond_2 "Bond passed, last 2 yrs (0/1)"
lab var closebond_5 "Bond passed, last 5 yrs (0/1)"
lab var HSG "High school graduates (\%)"
lab var COL_GRAD "College graduates (\%)"
lab var pct_single_mom "Single mothers (\%)"
lab var PCT_AA "African American (\%)"
lab var PCT_AS "Asian (\%)"
lab var PCT_HI "Hispanic (\%)"
lab var PCT_WH "White (\%)"
lab var PCT_MR "2+ races (\%)"
lab var temp_f "Average temp. ($^{\circ}$ F)"
lab var coastal "Coastal (0/1)"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_sum_stats_selection_coastal.tex", write replace

** CATEGORY EMPTY CONTROL EMPTY ANY:T  ANY:T-C EMPTY HVAC:T HVAC:T-C EMPTY LIGHT:T LIGHT:T-C
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}lccc}" _n
file write myfile "\toprule" _n
file write myfile "Characteristic & Untreated & Treated & T-U \\" _n
file write myfile "\midrule" _n
foreach var of varlist qkw_hour {

	local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
    			local mean = string(r(p),"%6.2f")
				
	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ " _n	
	
}
foreach var of varlist  year {

	local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* CONTROL
	summ `var' if evertreated_any == 0
	file write myfile " &" %4.0f (r(mean)) _tab

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %4.0f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %4.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/

	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%4.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%4.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ \midrule " _n	
	
}

foreach var of varlist enr_total API_BASE  {
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.0f (r(mean)) _tab

** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.0f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.0f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/

	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.0f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ " _n	
	
 }
 

foreach var of varlist closebond_2 closebond_5 HSG COL_GRAD pct_single_mom PCT_AA PCT_AS PCT_HI PCT_WH { 
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab

	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/
	
	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}
	file write myfile "\\ " _n	
	
 
 }
 
file write myfile "\midrule " _n	

 
 qui foreach var of varlist temp_f coastal cde_lat cde_lon {
 local lablocal: var label `var'
	file write myfile "`lablocal'" _tab
	* UNTREATED
	summ `var' if evertreated_any == 0
	file write myfile " &" %6.1f (r(mean)) _tab
	
	** ANY
	summ `var' if evertreated_any == 1
	file write myfile " &" %6.1f (r(mean)) _tab
	ttest `var', by(evertreated_any)
	file write myfile " &" %6.1f (r(mu_2)-r(mu_1))
	/*if (abs(r(p))<0.01) {
		file write myfile "***"
	}
	else if (abs(r(p))<0.05) {
		file write myfile "**"
	} 
	else if (abs(r(p))<0.1) {
		file write myfile "*"	
	}
	*/

	*** ANY
	file write myfile " \\" _n
		file write myfile "&" _tab

	summ `var' if evertreated_any == 0, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	summ `var' if evertreated_any == 1, det
			local mean = string(r(sd),"%6.1f")

	file write myfile " (`mean') & " _tab

	ttest `var', by(evertreated_any)
			local mean = string(r(p),"%6.2f")

	if "`mean'" == "0.00" {
	file write myfile " [$<$0.01] " _tab
	}
	else {
	file write myfile " [`mean'] " _tab
	}

	file write myfile "\\ " _n	
 }
 	file write myfile "\midrule " _n	

 qui {
 tab qkw_hour if evertreated_any == 0
 local ctrln = r(N)
  tab qkw_hour if evertreated_any == 1
 local anyn = r(N)
file write myfile "Number of schools &`ctrln' & `anyn' \\" _n

 }
file write myfile "\bottomrule" _n
file write myfile "\end{tabular*}" _n
file close myfile

}


************************************************
************************************************






************************************************
************************************************


***** TABLE: HETEROGENEITY (EBAYES)
{

use "$dirpath_data_int/MONTHLY_heterogeneity_by_characteristics_eb.dta", clear
local nspec = 7

local label_b_cons "Constant"
local label_b_hvac_dummy "HVAC only (0/1)"
local label_b_light_dummy "Lighting only (0/1)"
local label_b_hvac_light "HVAC and Lighting (0/1)"
local label_b_API_BASE "Academic perf. index (200-1000)" 
local label_b_cde_lon "Longitude"
local label_b_cde_lat "Latitude"
local label_b_enr_total "Total enrollment"
local label_b_poverty_rate "Poverty rate"
local label_b_temp_f "Average temperature ($^{\circ}$ F)"
local label_b_mean_energy_use "Hourly energy consumption (kWh)"
local label_b_tot_kwh "Expected savings (kWh)"
local label_b_coastal "Coastal (0/1)"
local label_b_hvaccoastal "Coastal $\times$ HVAC"


capture file close myfile
file open myfile using "$dirpath_results_final/tab_heterogeneity_eb.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\thispagestyle{empty}" _n
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " 
forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n ///
"\toprule " _n
file write myfile "Variable"
forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
}
file write myfile " \\ \midrule " _n

foreach var in "cons" "hvac_dummy" "light_dummy" "hvac_light" "coastal" "cde_lon" "cde_lat" "temp_f" "enr_total" "API_BASE" "poverty_rate" "tot_kwh" "hvaccoastal"{
file write myfile "`label_b_`var''"  
forvalues i = 1(1)`nspec' {
  summ b_`var' if spec == `i'
  local mean = string(r(mean), "%6.2f")
  if (r(N) == 0) {
  file write myfile "&"
  }
  else {
  file write myfile "& `mean'"
  }
  }
  file write myfile " \\ " _n
forvalues i = 1(1)`nspec' {
  summ se_`var' if spec == `i'
  local mean = string(r(mean), "%6.2f")
  if (r(N) == 0) {
  file write myfile "& "
  }
  else {
  file write myfile "& (`mean')"
  }
  }
  file write myfile "\\ "_n

  }

file write myfile "\midrule " _n 
	local lablocal: var label nobs
	file write myfile "Number of schools" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec==`i'
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
file write myfile "\\ " _n		
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}










******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS BY BOND STATUS (BINARY, LEVELS, SAMPLES)
{
use "$dirpath_data_int/RESULTS_monthly_heterogeneity_by_bond.dta", clear
local nspec 5
replace spec = spec - 1

keep if yvar == "qkw_hour"
gen bond = ""
replace bond = "b" if bonds == ""
replace bond = "y" if bonds == "if ever_treat_bond == 1"
replace bond = "n" if bonds == "if ever_treat_bond == 0"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_bondheterogeneity.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach bonds in "b" "y" "n" {
if "`bonds'" == "b" {
  local panel = "\emph{Panel A: All schools}"
}
else if "`bonds'" == "y" {
  local panel = "\emph{Panel B: Schools with bonds}"
}
else if "`bonds'" == "n" {
  local panel = "\emph{Panel C: Schools without bonds}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n

	file write myfile "\quad Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & bond == "`bonds'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& bond == "`bonds'"
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	/*
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	*/
	file write myfile "\\ " _n
file write myfile "\quad Point estimate" 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& bond == "`bonds'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& bond == "`bonds'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& bond == "`bonds'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}





******* TABLE: ML RESULTS BY BOND STATUS (BINARY, LEVELS, SAMPLES)
{
use "$dirpath_data_int/RESULTS_monthly_heterogeneity_by_bond.dta", clear
local nspec 5
replace spec = spec - 1

keep if yvar == "prediction_error4"
gen bond = ""
replace bond = "b" if bonds == ""
replace bond = "y" if bonds == "if ever_treat_bond == 1"
replace bond = "n" if bonds == "if ever_treat_bond == 0"

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_bondheterogeneity.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

foreach bonds in "b" "y" "n" {
if "`bonds'" == "b" {
  local panel = "\emph{Panel A: All schools}"
}
else if "`bonds'" == "y" {
  local panel = "\emph{Panel B: Schools with bonds}"
}
else if "`bonds'" == "n" {
  local panel = "\emph{Panel C: Schools without bonds}"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
file write myfile "\\" _n

	file write myfile "\quad Realization rate " 
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & bond == "`bonds'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& bond == "`bonds'"
		local savings = r(mean)
		local rate = string(`beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & `rate' "
		}
	}
	/*
	file write myfile "\\ " _n
	forvalues i = 1(1)`nspec' {
		summ se_aggregate if spec == `i' & subsample == "`s'"
		local se_beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'"
		local savings = r(mean)
		local se_rate = string(-`se_beta'/`savings',"%6.2f")
		if (r(N) != 0) {
			file write myfile " & (`se_rate') "
		}
	}
	*/
	file write myfile "\\ " _n
file write myfile "\quad Point estimate" 

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& bond == "`bonds'"
		local mean = string(r(mean),"%6.2f")
	if (r(N) != 0) {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& bond == "`bonds'"
				local mean = string(r(mean),"%6.2f")
			if (r(N) != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& bond == "`bonds'"
		if (r(N) != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}







******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS, MONTH COLLAPSE)
{
use "$dirpath_data_int/RESULTS_additional_collapses.dta", clear

gen estimator = ""
replace estimator = "davis" if xvar == "davis binary"
replace estimator = "reguant" if xvar == ""

keep if yvar == "qkw_hour" & collapse == "month"
local nspec 6
replace spec = spec-1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_monthcollapse.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}





******* TABLE: ML RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS, MONTH COLLAPSE)
{
use "$dirpath_data_int/RESULTS_additional_collapses.dta", clear

gen estimator = ""
replace estimator = "davis" if xvar == "davis binary"
replace estimator = "reguant" if xvar == ""

keep if yvar == "prediction_error4" & collapse == "month"
local nspec 6
replace spec = spec-1

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_monthcollapse.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}





******* TABLE: DIFFERENCE-IN-DIFFERENCE RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS, YEAR COLLAPSE)
{
use "$dirpath_data_int/RESULTS_additional_collapses.dta", clear

gen estimator = ""
replace estimator = "davis" if xvar == "davis binary"
replace estimator = "reguant" if xvar == ""

keep if yvar == "qkw_hour" & collapse == "year"
local nspec 2
replace spec = spec-1
replace spec = 2 if spec == 4

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_regressions_binary_davis_reguant_yearcollapse.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School FE       & Yes & Yes  \\" _n
file write myfile "Year FE & No & Yes  \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}





******* TABLE: ML RESULTS WITH DAVIS + REGUANT SAVINGS (BINARY, LEVELS, YEAR COLLAPSE)
{
use "$dirpath_data_int/RESULTS_additional_collapses.dta", clear

gen estimator = ""
replace estimator = "davis" if xvar == "davis binary"
replace estimator = "reguant" if xvar == ""

keep if yvar == "prediction_error4" & collapse == "year"
local nspec 2
replace spec = spec-1
replace spec = 2 if spec == 4

capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_yearcollapse.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School FE       & Yes & Yes  \\" _n
file write myfile "Year FE & No & Yes  \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}








******* TABLE:ML RESULTS WITH DAVIS + REGUANT SAVINGS (DOUBLE LASSO)
{
use"$dirpath_data_int/RESULTS_monthly_doublelasso.dta", clear
gen estimator = ""
replace estimator = "davis" if xvar == "davis binary"
replace estimator = "reguant" if xvar == ""
replace spec = spec-1

local nspec 5
capture file close myfile
file open myfile using "$dirpath_results_final/tab_aggregate_predictions_binary_davis_reguant_doublelasso.tex", write replace
if "`standalone'" == "_standalone" {
 file write myfile "\documentclass[12pt]{article}" _n
 file write myfile "\usepackage{amsmath}" _n
 file write myfile "\usepackage{tabularx}" _n
 file write myfile "\usepackage{booktabs}" _n
 file write myfile "\begin{document}" _n
 file write myfile "\pagenumbering{gobble}" _n
 file write myfile "\small"
}	
file write myfile "\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}} l " _n

forvalues i = 1(1)`nspec' {
	file write myfile " c "
}
file write myfile "}" _n 
file write myfile "\toprule " _n


forvalues i = 1(1)`nspec' {
	file write myfile " & (`i') "
} 

file write myfile " \\ \midrule " _n

local s = 0

foreach estimator in "davis" "reguant"  {
if "`estimator'" == "davis" {
  local panel = "\emph{Panel A: Average program estimates}"
  local vtitle1 = "Realization rate"
  local vtitle2 = "Point estimate"
}
else if "`estimator'" == "reguant" {
  local panel = "\emph{Panel B: Average school-specific estimates}"
  local vtitle1 = ""
  local vtitle2 = "Realization rate"
}

file write myfile "\multicolumn{`nspec'}{l}{`panel'}"
/*
forvalues i = 1(1)`nspec' {
 file write myfile " & "
}
*/
file write myfile "\\" _n
if "`vtitle1'" == "Realization rate" {
     file write myfile "\quad `vtitle1'"
	forvalues i = 1(1)`nspec' {
		summ beta_aggregate if spec == `i' & subsample == "`s'" & estimator == "`estimator'"
		local beta = r(mean)
		summ davis_denominator if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local savings = r(mean)
		if "`estimator'" == "reguant'" {
		local savings = 1 
		}
		local rate = string(`beta'/`savings',"%6.2f")
		if (`r(N)' != 0) {
			file write myfile " & `rate' "
		}
	}
	file write myfile "\\ " _n
}
    file write myfile "\quad `vtitle2'"

forvalues i = 1(1)`nspec' { 
	summ beta_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		local mean = string(r(mean),"%6.2f")
	if (`r(N)' != 0)  {
		file write myfile " & `mean' "
	}
}		
file write myfile "\\ " _n
		forvalues i = 1(1)`nspec' {
			summ se_aggregate if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
				local mean = string(r(mean),"%6.2f")
			if (`r(N)' != 0) {
				file write myfile " & (`mean') "
			}
		}
file write myfile "\\ "_n
	file write myfile "\quad Observations" 
	forvalues i = 1(1)`nspec' {
		summ nobs if spec == `i'& subsample == "`s'" & estimator == "`estimator'"
		if (`r(N)' != 0) {
			file write myfile " & " %10.0fc (r(mean)) " "
		}
	}
	file write myfile "\\ " _n		
	

	file write myfile "\midrule " _n 
}

file write myfile "School-Hour FE       & Yes & Yes & Yes & Yes & Yes  \\" _n
file write myfile "School-Hour-Month FE & No & Yes & Yes & No & Yes  \\" _n
file write myfile "Time trend & No & No & Yes & No & No  \\" _n
file write myfile "Month of Sample FE & No & No & No & Yes & Yes \\" _n
file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}



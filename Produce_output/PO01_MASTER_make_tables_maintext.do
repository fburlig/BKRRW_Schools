************************************************
**** PRODUCE OUTPUT: MAKE MAIN TEXT TABLES
************************************************

** Table 1: Average characteristics of schools in the sample
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

** Table 2: Panel fixed effects results
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

** Table 3: Panel fixed effects results, samples
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

** Table 4: Machine learning results
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

** Table 5: Machine learning results, samples
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

** Table 6: Heterogeneity
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

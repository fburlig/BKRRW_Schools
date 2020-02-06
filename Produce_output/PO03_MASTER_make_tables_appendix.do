************************************************
**** PRODUCE OUTPUT: MAKE APPENDIX TABLES
************************************************

** Table B.1: Panel FE (Alternative SEs)
// THIS STILL NEEDS TO BE UPDATED WITH THE BOOTSTRAP SE

** Table B.2: Panel FE results (average school specific estimates; outliers)
{
use "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", clear
replace spec = 7 if spec == 6
keep if spec==7
keep if xvar == "reguant binary"
replace xvar = "savings binary" if xvar == "reguant binary"
append using "$dirpath_data_int/RESULTS_monthly_savings.dta"

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

** Table B.3: Matching results
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

** Table B.4: R^2s of prediction models across ML methods
// UPDATE ME TO ALSO INCLUDE PRED10?
{

use "$dirpath_data_int/varied_ml_methods_r2_post.dta", clear


keep if posttrain == 1 & treatment_school == 0

local ntypes "1 2 3 4 7 8 10"

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
	
	
	file write myfile "\midrule " _n 

file write myfile "Method & LASSO & LASSO & LASSO & LASSO & RF & RF & AVG\\" _n
file write myfile "Basic variables & X & X & X & X & X & X  & \\" _n
file write myfile "Hour-specific model & X & X & X & X & X &  & \\" _n
file write myfile "Untreated schools $-i$  & &  & X & X &  &  & \\" _n
file write myfile "Tuning parameter & Min & 1SE & Min & 1SE &  & & \\" _n

file write myfile "\bottomrule " _n 
file write myfile "\end{tabular*}" _n
file close myfile
}

** Table B.5: ML (Alternative SEs)
// THIS STILL NEEDS TO BE UPDATED WITH THE BOOTSTRAP SE

** Table B.6: Machine learning effects (average school specific estimates; outliers)
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

** Table B.7: Machine learning effects (alternative prediction methods)
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

** Table B.8: Effects of bond measures on energy use in untreated schools
{
use "$dirpath_data_int/RESULTS_monthly_BONDS.dta", clear
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

** Table B.9: Panel fixed effects results (donuts)
// need to add temperature
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

** Table B.10: Machine learning results (donuts)
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

** Table B.11: Panel fixed effects results (continuous treatment variable)
// add temperature?
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

** Table B.12: Machine learning results (continuous treatment variable)
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

** Table B.15: Panel fixed effects results (all hourly)
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
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

** Table B.16: Machine learning results (all hourly)
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

** Table B.22: Panel fixed effects (month collapse)
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

** Table B.24: Machine learning (month collapse)
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

** Table B.24: Machine learning results (double LASSO)
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

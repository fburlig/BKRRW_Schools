************************************************
**** READ PREDICTIONS DATA FROM R; BUILD IN STATA
************************************************

use "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", clear
summ school_id
local schoolidmax = r(max)
di `schoolidmax'

local build_forest = 0
local build_dl = 1
local build_prediction = 0
local build_varnames = 0

if (`build_forest'==1) {
*** PREDICTIONS BY BLOCKS *FOREST*
clear
cd "$dirpath_data_int/School specific/forest"
forvalues i = 1(1)`schoolidmax' {
di `i'
cap rm school_data_`i'_prediction_forest.dta
cap {

	insheet using "$dirpath_data_int/School specific/forest/school_data_`i'_prediction.csv", clear comma

	compress
	save "$dirpath_data_int/School specific/forest/school_data_`i'_prediction_forest.dta", replace	

}
}
****

clear
cap rm $dirpath_data_int/schools_predictions_forest.dta
cd "$dirpath_data_int/School specific/forest"
forvalues i = 1(1)`schoolidmax' {
	cap append using "school_data_`i'_prediction_forest.dta"
}
compress
cap drop v1 num*
save "$dirpath_data_int/schools_predictions_forest.dta", replace
}
***

if (`build_dl'==1) {
*** PREDICTIONS BY BLOCKS *DOUBLE LASSO*
clear
cd "$dirpath_data_int/School specific/double lasso"
forvalues i = 1(1)`schoolidmax' {
di `i'
forvalues b = 0(1)23 {
cap rm school_data_`i'_prediction_dl`b'.dta
cap {

	insheet using "$dirpath_data_int/School specific/double lasso/school_data_`i'_prediction_dl_block`b'.csv", clear comma

	*data cleaning
	gen school_id = `i'
	gen block = `b'
	rename qkw_hour qkw
	rename prediction_dl4 prediction9

	local m = 9
	replace prediction`m' = 0 if prediction`m' < 0
	replace prediction`m' = 1500 if prediction`m' > 1500
	gen prediction_error`m' = qkw - prediction`m'
	
	keep date block school_id prediction_error9 
	
	compress
	save "$dirpath_data_int/School specific/double lasso/school_data_`i'_prediction_dl`b'.dta", replace	
	
}
}
}
****

clear
cap rm $dirpath_data_int/schools_predictions_by_block_dl.dta
cd "$dirpath_data_int/School specific/double lasso"
forvalues i = 1(1)`schoolidmax' {
forvalues b = 0(1)23 {
	cap append using "school_data_`i'_prediction_dl`b'.dta"
}
}
compress
cap drop v1 num*
save "$dirpath_data_int/schools_predictions_by_block_dl.dta", replace

unique school_id
}
***

if (`build_prediction'==1) {
*** PREDICTIONS BY BLOCKS
clear
cd "$dirpath_data_int/School specific/prediction"
forvalues i = 1(1)`schoolidmax' {
di `i'
forvalues b = 0(1)23 {
cap {

	insheet using "$dirpath_data_int/School specific/prediction/school_data_`i'_bootstrap`b'.csv", clear comma
	save "$dirpath_data_temp/bootstrap.dta", replace
	
	insheet using "$dirpath_data_int/School specific/prediction/school_data_`i'_prediction_block`b'.csv", clear comma	
	merge 1:1 date using "$dirpath_data_temp/bootstrap.dta", nogen
	
	gen block = `b' 
	
	*data cleaning
	rename qkw_hour qkw

	* censoring prediction to avoid waky splines out of sample, generate errors
	forvalues m = 1(1)7 {
		cap {
			replace prediction`m' = 0 if prediction`m' < 0
			replace prediction`m' = 1500 if prediction`m' > 1500
			gen prediction_error`m' = qkw - prediction`m'
		}
	}
	
	forvalues m = 1(1)20 {
		cap {
			replace predbs`m' = 0 if predbs`m' < 0
			replace predbs`m' = 1500 if predbs`m' > 1500
			gen prediction_error_bs`m' = qkw - predbs`m' 
		}
	}
	
	keep date block school_id qkw prediction_error* trainindex

	compress
	save "$dirpath_data_int/School specific/prediction/school_data_`i'_prediction`b'.dta", replace	
	
}
}
}
****

clear
cap rm $dirpath_data_int/schools_predictions_by_block.dta
cd "$dirpath_data_int/School specific/prediction"
forvalues i = 1(1)2400 {
forvalues b = 0(1)23 {
	cap append using "school_data_`i'_prediction`b'.dta"
}
}
compress

* add forests without forced blocks, double lasso and post
merge 1:1 school_id block date using "$dirpath_data_int/schools_predictions_forest.dta", keep(1 3) nogen keepusing(prediction8)
merge 1:1 school_id block date using "$dirpath_data_int/schools_predictions_by_block_dl.dta", keep(1 3) nogen

* clean up forest predictions
local m = 8
replace prediction`m' = 0 if prediction`m' < 0
replace prediction`m' = 1500 if prediction`m' > 1500
gen prediction_error`m' = qkw - prediction`m' 

cap drop prediction? 
cap drop prediction_log?
cap drop prediction_error_log?
cap drop v1 
cap drop train_percent

order school_id block date trainindex qkw
save "$dirpath_data_int/schools_predictions_by_block.dta", replace

}
***

if (`build_varnames'==1) {

	* prepare data to merge
	cd "$dirpath_data_int/School specific/prediction"
	forvalues i = 1(1)`schoolidmax' {
	forvalues b = 1(1)24 {
		cap rm "$dirpath_data_temp/variables/school_varnames_`i'_`b'.dta"
		cap {
			insheet using "school_`i'_prediction_variables`b'.csv", clear comma
			gen school_id = `i'
			gen block = `b'
			save "$dirpath_data_temp/variables/school_varnames_`i'_`b'.dta", replace		
		}
	}
	}

	clear
	cap rm "$dirpath_data_int/schools_prediction_variables.dta"
	qui forvalues i = 1(1)`schoolidmax' {
	forvalues b = 1(1)24 {
		cap append using "$dirpath_data_temp/variables/school_varnames_`i'_`b'.dta"
	}
	}

	cap drop v1
	order school_id block model varname
	sort school_id block model varname
	by school_id block model: gen n = _n
	by school_id block model: gen N = _N

	sort school_id block model n
	save "$dirpath_data_int/schools_prediction_variables.dta", replace
}
***

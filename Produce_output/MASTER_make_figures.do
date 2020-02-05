************************************************
**** MAKE FINAL FIGURES
**** WRITTEN BY FIONA BURLIG (fiona.burlig@berkeley.edu)

************************************************
************************************************
**** SETUP:
clear all
set more off, perm
set scheme fb, perm
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

/* NB: To get these figures to appear as in the paper requires the scheme "fb",
   included with the replication file. 
*/
************************************************
************************************************


************************************************
*                                              *
*                   MAIN TEXT                  *
*                                              *
************************************************


************************************************
************************************************

******* FIGURE: LOCATIONS OF UNTREATED AND TREATED SCHOOLS
{
/* The two panels of this figure were generated in R,
 and combined (including adding titles) in Photoshop.
 
 R file: Analyze/jan4_map_tc.R
*/
}

************************************************
************************************************



******* FIGURE: DEMOGRAPHICS EVENT STUDY
{
** PREP DATA
{
foreach bp in "" "_BP" {

use "$dirpath_data_int/RESULTS_demographic_eventstudies`bp'.dta", clear

local lag = 4
local fwd = 6
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample esyr
by yvar ylab fe clustering controls subsample: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample  nobs nschools r2 esyr

}


** MAKE FIGURES

{
local outcome "enr_total"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr <6 & esyr > -6 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Number of students") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_enrtotal`bp'.pdf", replace


local outcome "staff_count"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr <6 & esyr > -6 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Number of staff") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_stafftotal`bp'.pdf", replace


local outcome "mathproficient"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr <6 & esyr > -6 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Percent of students proficient or better (math tests)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_mathproficient`bp'.pdf", replace



local outcome "elaproficient"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6 & esyr > -6, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 6& esyr > -6 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Percent of students proficient or better (ELA tests)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_elaproficient`bp'.pdf", replace

}

}
}




************************************************
************************************************


******* FIGURE: MACHINE LEARNING DIAGNOSTICS
{
{
** PANEL A

use "$dirpath_data_int/schools_predictions_by_block.dta", clear

* drop unbalanced days
bys school_id date: gen numblocks=_N
// drop if numblocks !=8
drop if numblocks!=24

* drop schools with less than two months of data
sort school_id date block
by school_id: gen numobs = _N
// drop if numobs < 8 * 60
drop if numobs < 24*60

sort school_id block trainindex
by school_id block trainindex: gen numtrain = _N

keep if trainindex == 1
keep school_id block numtrain
duplicates drop

merge 1:m school_id block using "$dirpath_data_int/schools_prediction_variables.dta", keep(3) nogen

keep if model == "levels_controls_se"
keep if n == N

twoway (scatter N numtrain, mcolor(gs10)) (lowess N numtrain, lwidth(thick) lcolor(midblue) lpattern(solid) ///
    text(150 -400 "A", color(black) size(huge))), ///
	scheme(fb) ytitle("Number of LASSO coefficients", size(4)) ///
	xtitle("Observations in training sample", size(4)) ylab(,labsize(4)) xlab(,labsize(4)) legend(off)
graph export "$dirpath_results_final/fig_ml_diagnostics_a.pdf", as(pdf) replace

}
{
** PANEL B
use "$dirpath_data_int/schools_prediction_variables.dta", clear
keep if model == "levels_controls_se"

gen holiday=strmatch(varname,"*holiday*")
unique varname if holiday==1

gen control=strmatch(varname,"*cqkw*")
unique varname if control==1

by school_id block: egen num_holiday = total(holiday)
by school_id block: egen num_control = total(control)
summ num_holiday, det
summ num_control, det
summ N if N==n, det

sum coef if holiday ==1, det
local 5pct = `r(p5)'
local 95pct = `r(p95)'
twoway (hist coef if holiday ==1 & coef > `5pct' & coef < `95pct', freq fc(gs12) lc(gs13) lw(thin) ///
   text(15200 -78 "B", color(black) size(huge))), ///
  scheme(fb) xtitle("Coefficient on holiday variable", size(4)) ytitle("Count of holiday variables", size(4)) ///
  ylab(0 "0" 5000 "5000" 10000 "10,000" 15000 "15,000", labsize(4)) xlab(, labsize(4))
graph export "$dirpath_results_final/fig_ml_diagnostics_b.pdf", as(pdf) replace
}
{
** PANEL C

use "$dirpath_data_int/schools_prediction_variables.dta", clear
keep if model == "levels_controls_se"

merge m:1 school_id using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", nogen

merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", nogen


gen evertreated = 0
replace evertreated = 1 if tot_kwh != 0 & tot_kwh > 0

preserve

keep if evertreated == 0 

foreach i in cqkw weekday month Temp holiday Intercept {
	gen `i' = strpos(varname,"`i'")
	replace `i'=1 if `i'>=1
	replace `i'=. if `i'==0
}

gen i2ts = 1 if Temp + month == 2 & Temp + month + weekday  != 3
gen i2tw = 1 if Temp + weekday == 2 & Temp + month + weekday  != 3
gen i2sw = 1 if month + weekday == 2  & Temp + month + weekday  != 3
gen i2hw = 1 if holiday + weekday == 2
gen i3tsw = 1 if Temp + month + weekday  == 3 


sort school_id block
foreach i in Intercept cqkw weekday month Temp holiday i2ts i2tw i2sw i2hw i3tsw {
	by school_id block: egen num_`i' = count(`i')
}


by school_id block: gen numcoefs = _N
foreach i in Intercept cqkw weekday month Temp holiday i2ts i2tw i2sw i2hw i3tsw {
	gen prop_`i' = num_`i'/numcoefs
}

gen check = prop_Intercept + prop_weekday + prop_month + prop_Temp + prop_holiday + prop_i2tw + prop_i2ts + prop_i2sw + prop_i2hw + prop_i3tsw + prop_cqkw
sum check

drop prop*


keep school_id block numcoefs num_*
duplicates drop

foreach i in Intercept cqkw weekday month Temp holiday i2ts i2tw i2sw i2hw i3tsw {
	gen prop_`i' = 0
	replace prop_`i' = 1 if num_`i' > 0 & num_`i' !=.
}



collapse(mean) prop*

gen dataset = "control"
reshape long prop_, i(dataset) j(selected_var) string
gsort -prop_

save "$dirpath_data_temp/control_lasso_vars.dta", replace

restore

keep if evertreated == 1

foreach i in cqkw weekday month Temp holiday Intercept {
	gen `i' = strpos(varname,"`i'")
	replace `i'=1 if `i'>=1
	replace `i'=. if `i'==0
}

gen i2ts = 1 if Temp + month == 2 & Temp + month + weekday  != 3
gen i2tw = 1 if Temp + weekday == 2 & Temp + month + weekday  != 3
gen i2sw = 1 if month + weekday == 2  & Temp + month + weekday  != 3
gen i2hw = 1 if holiday + weekday == 2
gen i3tsw = 1 if Temp + month + weekday  == 3 


sort school_id block
foreach i in Intercept cqkw weekday month Temp holiday i2ts i2tw i2sw i2hw i3tsw {
	by school_id block: egen num_`i' = count(`i')
}


by school_id block: gen numcoefs = _N
foreach i in Intercept cqkw weekday month Temp holiday i2ts i2tw i2sw i2hw i3tsw {
	gen prop_`i' = num_`i'/numcoefs
}

gen check = prop_Intercept + prop_weekday + prop_month + prop_Temp + prop_holiday + prop_i2tw + prop_i2ts + prop_i2sw + prop_i2hw + prop_i3tsw + prop_cqkw
sum check

drop prop*


keep school_id block numcoefs num_*
duplicates drop

foreach i in Intercept cqkw weekday month Temp holiday i2ts i2tw i2sw i2hw i3tsw {
	gen prop_`i' = 0
	replace prop_`i' = 1 if num_`i' > 0 & num_`i' !=.
}


collapse(mean) prop*

gen dataset = "treated"
reshape long prop_, i(dataset) j(selected_var) string
gsort -prop_

save "$dirpath_data_temp/treated_lasso_vars.dta", replace

use "$dirpath_data_temp/control_lasso_vars.dta"
append using "$dirpath_data_temp/treated_lasso_vars.dta"

gen trt = prop_
replace trt = . if dataset == "control"

gen ctrl = prop_
replace ctrl = . if dataset == "treated"

/*
label define lassovar 1 "Intercept" 2 "Other schools" ///
 5 "Temperature" 3 "Weekday" 4 "Month" ///
 6 "Temp. x Month x Weekday" 7 "Holiday" 8 "" ///
 9 "Season x Weekday" 10 "Weekday", replace
 
label values category lassovar
*/

rename selected_var category
replace category = proper(category)

replace category = "Temperature" if category=="Temp"
replace category = "Other schools" if category=="Cqkw"
replace category = "Temp x Month x Weekday" if category=="I3Tsw"
replace category = "Temp x Weekday" if category=="I2Tw"
replace category = "Month x Weekday" if category=="I2Sw"
replace category = "Temp x Month" if category=="I2Ts"
replace category = "Holiday x Weekday" if category=="I2Hw"

graph hbar trt ctrl, over(category, axis(noline) sort(ctrl) reverse) /// 
  scheme(fb) bar(1, color(gs12)) bar(2, color(midblue)) /// 
  text(-.55 0 "C", color(black) size(huge)) /// 
  ytitle("Fraction of school-block models selecting variable type") /// 
  ylabel(,nogrid) legend(position(6) order(1 "Untreated" 2 "Treated") rows(1)) ///
  yscale(range(0 1) noextend)

graph export "$dirpath_results_final/fig_ml_diagnostics_c.pdf", replace as(pdf)

}


** PANEL D
{
use "$dirpath_data_temp/newpred_formerge_by_block.dta", clear
merge m:1 cds_code date block using "$dirpath_data_int/full_analysis_data_trimmed.dta", keep(3) nogen keepusing(any_post_treat)
keep cds_code block posttrain prediction_error4 any_post_treat

*use "$dirpath_data_temp/monthly_by_block4_sample0.dta", clear
*keep cds_code block posttrain month qkw prediction_error* any_post_treat numobs
gegen byte treatment_school = max(any_post_treat), by(cds_code)
gcollapse (mean) prediction_error, by(posttrain treatment_school cds_code block)

sum prediction_error if posttrain > 0 & posttrain != . & treatment_school == 0, det
twoway (kdensity prediction_error if posttrain > 0 & posttrain != . & treatment_school == 0 ///
  & prediction_error > `r(p1)' & prediction_error < `r(p99)', lcolor(gs10) ///
      text(0.25 -20 "D", color(black) size(huge))), ///
  xline(`r(mean)') ///
  ytitle("", size(4)) xtitle("") xtitle("Prediction error (kWh)") ///
  legend(off) ///
    yscale(off noextend) xscale(noextend) 

graph export "$dirpath_results_final/fig_ml_diagnostics_d.pdf", replace

}


}



************************************************
************************************************


******* FIGURE: COMPARING MACHINE LEARNING ESTIMATORS
{
use "$dirpath_data_int/RESULTS_ml_estimators_levels_samples.dta", clear

keep if subsample=="$sample"

* !!! how robust is this to identify the specs? 
* it wasn't robust to having multiple samples!
gen prediction_error = .
replace prediction_error = 1 if _n < 7
replace prediction_error = 2 if _n > 6 & _n < 13
replace prediction_error = 3 if _n > 12 & _n < 19
replace prediction_error = 4 if _n > 18 & _n < 25
replace prediction_error = 5 if _n > 24 & _n < 31
replace prediction_error = 6 if _n > 30 & _n < 37
replace prediction_error = 7 if _n > 36 & _n < 43
replace prediction_error = 8 if _n > 42 

keep if prediction_error == 4

gen spec = .
replace spec = 1 if spec_desc == "bc"
replace spec = 2 if spec_desc == "bt"
replace spec = 3 if spec_desc == "bdd"
replace spec = 4 if spec_desc == "bcd"
replace spec = 5 if spec_desc == "btd"
replace spec = 6 if spec_desc == "b3d"

local nspec = 5

keep if subsample == "$sample"
keep spec *_aggregate
drop if spec == .
drop if beta_aggregate == .

keep *_aggregate spec  

label define speclab 1 "U" 2 "T" 3 "PD" 4 "UD" 5 "TD" 6 "DD" 
  
label values spec speclab   

gen order = .
replace order = 1 if spec == 1
replace order = 2 if spec == 4
replace order = 3 if spec == 2
replace order = 5 if spec == 3
replace order = 4 if spec == 5
replace order = 6 if spec == 6

label define orderlab 1 "U" 2 "UD" 3 "T" 4 "TD"  5 "PD" 6 "DD" 
label values order orderlab   



twoway (rspike ci95_lo_aggregate ci95_hi_aggregate order, lcolor(gs10) lwidth(thin)) ///
       (scatter beta_aggregate order, mlcolor(midblue) mfcolor(white) msize(medium)) ///
       (scatter beta_aggregate order if spec == 1 | spec == 4, mlcolor(gs13) mfcolor(gs14) msymbol(S) msize(medium) ///
	   	text(-5.2 1 "U") ///
		text(-5.2 2 "UD") ///
		text(-5.2 3 "T") ///
		text(-5.2 4 "TD") ///
		text(-5.2 5 "PD") ///
		text(-5.2 6 "DD")), ///
  yline(0, lcolor(gs7)) scheme(fb) ///
   ylabel(-5 -2.5 0 2.5) yscale(range(-5 2.5) noextend)  ///
  ytitle("Prediction error (kWh)") xtitle("") ///
  legend(off) xscale(off) xlabel(1(1)6, valuelabel)
  
graph export "$dirpath_results_final/fig_ml_estimators_levels.pdf", replace
}

************************************************
************************************************


******* FIGURE: EXPECTED SAVINGS RELATIVE TO CONSUMPTION
{
use "$dirpath_data_temp/demographics_for_selection_regs.dta", clear
merge 1:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", nogen
merge 1:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", nogen

summ mean_energy_use, det
gen sample2 = 1
replace sample2 = 0 if mean_energy_use < `r(p1)' & mean_energy_use != .
replace sample2 = 0 if mean_energy_use > `r(p99)' & mean_energy_use != .

* treatment dummies

gen evertreated_h = 0
replace evertreated_h = 1 if tot_kwh_hvac >0 & tot_kwh_hvac !=. & tot_kwh_hvac==tot_kwh

gen evertreated_l = 0
replace evertreated_l = 1 if tot_kwh_light >0 & tot_kwh_light !=. & tot_kwh_light==tot_kwh

gen purecontrol = 0
replace purecontrol = 1 if tot_kwh == 0

gen evertreated_any = 0
replace evertreated_any = 1 if tot_kwh >0 & tot_kwh !=.

gen evertreated_hvac_pure = .
replace evertreated_hvac_pure = 0 if purecontrol == 1
replace evertreated_hvac_pure = 1 if evertreated_h == 1

gen evertreated_light_pure = .
replace evertreated_light_pure = 0 if purecontrol == 1
replace evertreated_light_pure = 1 if evertreated_l == 1
 

* savings variables
gen proj_sav_cat = 0
replace proj_sav_cat = tot_kwh if evertreated_any == 1
replace proj_sav_cat = tot_kwh_hvac if evertreated_hvac_pure == 1
replace proj_sav_cat = tot_kwh_light if evertreated_light_pure == 1
label var proj_sav_cat "Projected Savings (kWh)"
 
gen proj_sav_pct = proj_sav_cat/(mean_energy_use*24*365)

twoway hist proj_sav_pct if proj_sav_pct != 0 & proj_sav_pct != . & proj_sav_pct < 1, fc(gs12) lc(gs13) lw(thin) freq ///
	 legend(off) ///
	 xscale(range(0 1)) xlab(0(0.2)1) /// 
	scheme(fb) ytitle("Number of schools") xtitle("Expected savings (as share of average electricity consumption)")	
graph export "$dirpath_results_final/fig_savings.pdf", as(pdf) replace
}

************************************************
************************************************


******* FIGURE: MACHINE LEARNING RESULTS BY HOUR-BLOCK (BINARY, LEVELS)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_block.dta", clear
keep if yvar == "prediction_error4" 

drop if spec == .
drop if beta_block1 == .

keep beta_block* ci95_lo* ci95_hi* spec

reshape long beta_block ci95_lo_block ci95_hi_block, i(spec) j(block)

replace block = block - 1

label define blocklab 0 "Average" 1 "Midn. to 3 AM" 2 "3 AM to 6 AM" 3 "6 AM to 9 AM" ///
  4 "9 AM to Noon" 5 "Noon to 3 PM" 6 "3 PM to 6 PM" /// 
  7 "6 PM to 9 PM" 8 "9 PM to Midn."
  
label values block blocklab   
gen blockplus1 = block -0.1


}

** MAKE FIGURES
{

twoway ///
  (rspike ci95_lo ci95_hi blockplus1 if spec == 1 , lcolor(gs12) lwidth(thin) lpattern(solid)) ///
  (line beta_block blockplus1 if spec == 1 , lcolor(midblue*0.2) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block blockplus1 if spec == 1 , mlcolor(midblue*0.2) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (rspike ci95_lo ci95_hi block if spec == 5 , lcolor(gs12) lwidth(thin) lpattern(solid)) ///
  (line beta_block block if spec == 5 , lcolor(midblue) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if spec == 5, mlcolor(midblue) mfcolor(white)  msymbol(O) msize(medium)), /// 
  yline(0, lcolor(gs7)) scheme(fb) ///
  ylabel(5 0 -5 -10, labsize(5)) yscale(range(5 -10) noextend)   ///
  ytitle("Prediction error (kWh)", size(5)) xtitle("Hour of day", size(5)) ///
  legend(off) xlabel(0 4 8 12 16 20 24, valuelabel  labsize(5)) xscale(range(0 23) noextend)
graph export "$dirpath_results_final/fig_blockwise_ml_levels_binary.pdf", replace


/*
  legend(off) xlabel(1 "Midn. to 3 AM" 2 "3 AM to 6 AM" 3 "6 AM to 9 AM" ///
  4 "9 AM to Noon" 5 "Noon to 3 PM" 6 "3 PM to 6 PM" /// 
  7 "6 PM to 9 PM" 8 "9 PM to Midn.", valuelabel angle(45) labsize(4))
*/


}
}



************************************************
************************************************



******* FIGURE: SCHOOL-SPECIFIC EFFECTS
{
use "$dirpath_data_int\RESULTS_monthly_heterogeneity.dta", clear

count if yvar != ""
forvalues v = 1(1)`r(N)' {
	local pred = subinstr(yvar[`v'],"iction_error","",.)
	local spec = spec[`v']
	local s = subsample[`v']
	rename beta`v'1 beta_`pred'_`spec'_sample`s'
}

rename school_id141 school_id
keep school_id beta_*

collapse (mean) beta_*, by(school_id)

* merge in data
merge m:1 school_id using "$dirpath_data_int/School specific/schoolid_cdscode_map.dta", keep(3) nogenerate
merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_int/School specific/cdscode_samplesize.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/demographics_for_selection_regs.dta", keep(3)

* savings variables
gen savings = -tot_kwh/(365*24)

cd "$dirpath_results_prelim"

local regcase "pred11"
local spec 3
local s 0

local beta_pick = "beta_`regcase'_`spec'_sample`s'"

summ `beta_pick' if savings != 0, det
local l_thr_beta = -r(p99)
local u_thr_beta = -r(p1)

summ `beta_pick' if savings == 0, det
local l_thr_beta0 = -r(p99)
local u_thr_beta0 = -r(p1)

summ savings if savings != 0, det
local l_thr_sav = -r(p99)
local u_thr_sav = -r(p1)

replace savings = -savings
replace `beta_pick' = -`beta_pick'

reg `beta_pick' savings [w=numobs]
reg `beta_pick' savings [w=numobs] if savings < `u_thr_sav'
reg `beta_pick' savings [w=numobs] if savings < `u_thr_sav' & savings > `l_thr_sav'
reg `beta_pick' savings [w=numobs] if `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta' & savings < `u_thr_sav' & savings > `l_thr_sav'
local slope_sav = round(_b[savings],.01)


twoway (scatter  `beta_pick' savings, mcolor(gs10))  ///
		(pci 41 40 41 40, lcolor(gs12) lwidth(thin) ///
		text(48 46 "Slope:", size(7)) text(38 46 "`slope_sav'", size(7)) text(75 -8.5 "A", size(vhuge))) ///	
        (lfit `beta_pick' savings [w=numobs] , lcolor(midblue) lstyle(solid) lwidth(medthick))  ///	
		if `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta' & savings < `u_thr_sav' & savings > `l_thr_sav', graphregion(color(white))  ///
		legend(off) scheme(fb) xtitle("Expected savings (kWh)", size(7)) ytitle("Estimated savings (kWh)", size(7)) ///
		yscale(range(-75 75) noextend) xscale(noextend) ylab(-75 -50 -25 0 25 50 75, labsize(7)) xlab(, labsize(7)) yline(0, lcolor(gs7) lwidth(thin)) ///
		saving("$dirpath_results_prelim/heterogeneous_betas_lfit_`regcase'_spec`spec'_sample`s'_text.gph", replace)

		
twoway (kdensity `beta_pick' [w=numobs] if savings==0 & `beta_pick' < `u_thr_beta0' & `beta_pick' > `l_thr_beta0', horizontal lcolor(gs12) lstyle(solid) lwidth(medium)) ///
	(kdensity `beta_pick' [w=numobs] if savings > 0  & `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta', horizontal lcolor(midblue) lstyle(solid) lwidth(medium) ///
	text(75 -0.04 "B", size(vhuge))) ///
	, scheme(fb) legend(off) ytitle("") xtitle("Density", color(white)) ///
	xla(,tlength(0) labcolor(white) labsize(7)) xscale(lcolor(white)) ///
	yscale(range(-75 75) noextend) ylab(-75 -50 -25 0 25 50 75, labsize(7)) ///
	 yline(0, lcolor(gs7) lwidth(thin)) ///
		saving("$dirpath_results_prelim/heterogeneous_betas_distribution_`regcase'_spec`spec'_sample`s'_v2.gph", replace)

** graph combine
graph combine "$dirpath_results_prelim/heterogeneous_betas_lfit_`regcase'_spec`spec'_sample`s'_text.gph" "$dirpath_results_prelim/heterogeneous_betas_distribution_`regcase'_spec`spec'_sample`s'_v2.gph", ///
       rows(1)    ///
	   scheme(fb) ysize(4) xsize(10) ///
      saving(heterogeneous_betas_`regcase'_spec`spec'_sample`s'_combo, replace)
graph export "$dirpath_results_final/fig_school_specific.pdf", replace as(pdf)

}





************************************************
************************************************

******* FIGURE: KDENSITIES
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_hourly_withtemp.dta", clear
replace yvar = "qkw_temp" if yvar=="qkw_hour"
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if yvar == "qkw_hour" | yvar == "prediction_error4" | yvar == "qkw_temp"
keep if strpos(xvar, "binary")
gen rate = beta_aggregate / davis_denominator
}

drop if spec==1
** MAKE FIGURES
{

twoway ///
   (kdensity rate if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity rate if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity rate if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_rate.pdf", replace


twoway ///
   (kdensity beta if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity beta if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity beta if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("Energy use (kWh)") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_betas.pdf", replace

preserve
keep if spec==5 | spec==6
twoway ///
   (kdensity rate if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity rate if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity rate if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_rate_spec5.pdf", replace


twoway ///
   (kdensity beta if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity beta if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity beta if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_betas_spec5.pdf", replace
restore

}

}



******* FIGURE: DIFFERENCE-IN-DIFFERENCE EVENT STUDY (LEVELS, MULTIPLE SPECS -- MAIN TEXT)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_eventstudies.dta", clear

replace spec = spec - 1

keep if yvar == "qkw_hour" & subsample == "0"

local lag = 7
local fwd = 9
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls subsample postctrls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample postctrls esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample postctrls: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample postctrls esyr
by yvar ylab fe clustering controls subsample postctrls: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample postctrls nobs nschools r2 esyr

keep if strpos(fe, "qdate")

}


** MAKE FIGURES

{
	   
	   
local outcome "qkw_hour"
	   
twoway  ///
       (line beta esyr if spec == 1 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 2 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 3 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 4 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (rspike ci95_lo ci95_hi esyr if spec == 5 & yvar == "`outcome'", lcolor(gs6) lwidth(medium)) ///
       (line beta esyr if spec == 5 & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == 5 & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium) msymbol(circle) /// 
       text(4 -7.75 "`spec'", color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Prediction error (kWh)") /// 
	   xtitle("Quarters to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-6 -4 -2 0 2 4 6 8 10) ylabel(-6(2)4) yscale(range(-6 4))	   
	   
graph export "$dirpath_results_final/Appendix/fig_eventstudy_allspecs_dd_levels.pdf", replace
}


}


******* FIGURE: DIFFERENCE-IN-DIFFERENCE EVENT STUDY (LEVELS, BALANCED PANEL -- MAIN TEXT)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_eventstudies_yearly_BP.dta", clear

replace spec = spec - 1

keep if spec == 4

keep if yvar == "qkw_hour" & subsample == "0"

local lag = 3
local fwd = 3
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls subsample postctrls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample postctrls esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample postctrls: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample postctrls esyr
by yvar ylab fe clustering controls subsample postctrls: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample postctrls nobs nschools r2 esyr


}


** MAKE FIGURES

{
	   
	   
local outcome "qkw_hour"
	   
twoway  ///
       (line beta esyr if spec == 1 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 2 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 3 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 4 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (rspike ci95_lo ci95_hi esyr if spec == 4 & yvar == "`outcome'", lcolor(gs6) lwidth(medium)) ///
       (line beta esyr if spec == 4 & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == 4 & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium) msymbol(circle) /// 
       text(4 -7.75 "`spec'", color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Energy consumption (kWh)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 -1 0 1 2 3 4) /*ylabel(-6(2)4) yscale(range(-6 4))	*/   
	   
graph export "$dirpath_results_final/Appendix/fig_eventstudy_allspecs_dd_levels_BP.pdf", replace
}


}


************************************************
************************************************

******* FIGURE: MACHINE LEARNING EVENT STUDY (LEVELS, MULTIPLE SPECS -- MAIN TEXT)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_eventstudies.dta", clear

local outcome "prediction_error4"

keep if yvar == "`outcome'" & subsample == "0"
replace spec = spec - 1

local lag = 7
local fwd = 9
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls subsample postctrls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample postctrls esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample postctrls: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample postctrls esyr
by yvar ylab fe clustering controls subsample postctrls: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample postctrls nobs nschools r2 esyr

keep if strpos(fe, "qdate")

}


** MAKE FIGURES

{

local outcome "prediction_error4"

twoway  ///
       (line beta esyr if spec == 1 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 2 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 3 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (line beta esyr if spec == 4 & yvar == "`outcome'", lcolor(gs13) lwidth(medium) lpattern(solid)) ///
       (rspike ci95_lo ci95_hi esyr if spec == 5 & yvar == "`outcome'", lcolor(gs6) lwidth(medium)) ///
       (line beta esyr if spec == 5 & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == 5 & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium) msymbol(circle) /// 
       text(4 -7.75 "`spec'", color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Prediction error (kWh)") /// 
	   xtitle("Quarters to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-6 -4 -2 0 2 4 6 8 10) ylabel(-6(2)4) yscale(range(-6 4))	   

graph export "$dirpath_results_final/Appendix/fig_eventstudy_allspecs_ml_levels.pdf", replace
}


}




************************************************
************************************************



************************************************
************************************************

************************************************
*                                              *
*                   APPENDIX                   *
*                                              *
************************************************


************************************************
************************************************


******* FIGURE: DIFFERENCE-IN-DIFFERENCE EVENT STUDY (LEVELS, MULTIPLE SPECS -- APPX)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_eventstudies.dta", clear

keep if yvar == "qkw_hour" & subsample == "0"

local lag = 7
local fwd = 9
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls subsample postctrls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample postctrls esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample postctrls: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample postctrls esyr
by yvar ylab fe clustering controls subsample postctrls: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample postctrls nobs nschools r2 esyr

keep if strpos(fe, "qdate")

}


** MAKE FIGURES

{
local outcome "qkw_hour"
forvalues spec = 1/6 {

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'", lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 "`spec'", color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Energy consumption (kWh)") /// 
	   xtitle("Quarters to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-6 -4 -2 0 2 4 6 8 10) ylabel(-6(2)4) yscale(range(-6 4))

graph export "$dirpath_results_final/Appendix/fig_eventstudy_`spec'_dd_levels.pdf", replace
}
}

{
local outcome "qkw_hour"
local spec = 6
twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'", lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium)),  /// 
	   scheme(fb) ytitle("Energy consumption (kWh)") /// 
	   xtitle("Quarters to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-6 -4 -2 0 2 4 6 8 10) /*ylabel(-0.06(0.03)0.06) yscale(range(-0.06 0.06))*/

graph export "$dirpath_results_final/fig_eventstudy_dd_levels.pdf", replace
}

}


************************************************
************************************************

******* FIGURE: DIFFERENCE-IN-DIFFERENCE EVENT STUDY YEARLY (LEVELS, MULTIPLE SPECS -- APPX)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_eventstudies_yearly.dta", clear

keep if (yvar == "qkw_hour" | yva == "prediction_error4") & subsample == "0"

local lag = 4
local fwd = 4
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls subsample postctrls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample postctrls esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample postctrls: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample postctrls esyr
by yvar ylab fe clustering controls subsample postctrls: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample postctrls nobs nschools r2 esyr

}


** MAKE FIGURES
{
local outcome "qkw_hour"
local spec = 1
twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'", lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium)),  /// 
	   scheme(fb) ytitle("Energy consumption (kWh)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /*ylabel(-0.06(0.03)0.06) yscale(range(-0.06 0.06))*/

graph export "$dirpath_results_final/fig_eventstudy_dd_levels_yearly.pdf", replace
}

** MAKE FIGURES
{
local outcome "prediction_error4"
local spec = 1
twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'", lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium)),  /// 
	   scheme(fb) ytitle("Energy consumption (kWh)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /*ylabel(-0.06(0.03)0.06) yscale(range(-0.06 0.06))*/

graph export "$dirpath_results_final/fig_eventstudy_ml_levels_yearly.pdf", replace
}

}

************************************************
************************************************


******* FIGURE: MACHINE LEARNING EVENT STUDY (LEVELS, MULTIPLE SPECS -- APPX)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_eventstudies.dta", clear

local outcome "prediction_error4"

keep if yvar == "`outcome'" & subsample == "0"

local lag = 7
local fwd = 9
local count = 1
forvalues i = `lag'(-1)2{
	rename *_min`i' *`count'
	local count = `count' + 1
}
local count = `count' + 1
rename *_0 *`count'
local count = `count' + 1
forvalues i = 1(1)`fwd' {
	rename *_plus`i' *`count'
	local count = `count' + 1
}

reshape long beta se tscore pvalue stars ci95_lo ci95_hi, i(yvar ylab fe clustering controls subsample postctrls nobs nschools r2) j(esyr)

sort yvar ylab fe clustering controls subsample postctrls esyr
gen expcase = 1
by yvar ylab fe clustering controls subsample postctrls: replace expcase = 2 if _n==_N
expand expcase
sort yvar ylab fe clustering controls subsample postctrls esyr
by yvar ylab fe clustering controls subsample postctrls: replace esyr = `lag' if _n==_N
drop expcase

replace beta = 0 if esyr == `lag'
replace se = 0 if esyr == `lag'
replace ci95_lo = 0 if esyr == `lag'
replace ci95_hi = 0 if esyr == `lag'

replace esyr = esyr-`lag'

sort yvar ylab fe clustering controls subsample postctrls nobs nschools r2 esyr

keep if strpos(fe, "qdate")

}


** MAKE FIGURES

{
forvalues spec = 1/6 {
twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'", lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium)  /// 
       text(4 -7.75 "`spec'", color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Prediction error (kWh)") /// 
	   xtitle("Quarters to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-6 -4 -2 0 2 4 6 8 10) ylabel(-6(2)4) yscale(range(-6 4))

graph export "$dirpath_results_final/Appendix/fig_eventstudy_`spec'_ml_levels.pdf", replace
}
}

{
local spec = 6
twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'", lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'", lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" , mlcolor(midblue) mfcolor(white) msize(medium)),  /// 
	   scheme(fb) ytitle("Prediction error (kWh)") /// 
	   xtitle("Quarters to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-6 -4 -2 0 2 4 6 8 10) /*ylabel(-0.06(0.03)0.06) yscale(range(-0.06 0.06))*/

graph export "$dirpath_results_final/fig_eventstudy_ml_levels.pdf", replace
}

}


************************************************
************************************************


******* FIGURE: DIFFERENCE-IN-DIFFERENCE RESULTS BY HOUR-BLOCK (BINARY, LEVELS)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_block.dta", clear
keep if yvar == "qkw_hour" 

drop if spec == .
drop if beta_block1 == .

keep beta_block* ci95_lo* ci95_hi* spec

reshape long beta_block ci95_lo_block ci95_hi_block, i(spec) j(block)


replace block = block - 1
label define blocklab 0 "Average" 1 "Midn. to 3 AM" 2 "3 AM to 6 AM" 3 "6 AM to 9 AM" ///
  4 "9 AM to Noon" 5 "Noon to 3 PM" 6 "3 PM to 6 PM" /// 
  7 "6 PM to 9 PM" 8 "9 PM to Midn."
  
label values block blocklab   
gen blockplus1 = block -0.1

}

** MAKE FIGURES
{


twoway ///
  (rspike ci95_lo ci95_hi blockplus1 if spec == 1 , lcolor(gs12) lwidth(thin) lpattern(solid)) ///
  (line beta_block blockplus1 if spec == 1 , lcolor(midblue*0.2) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block blockplus1 if spec == 1 , mlcolor(midblue*0.2) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (rspike ci95_lo ci95_hi block if spec == 5 , lcolor(gs12) lwidth(thin) lpattern(solid)) ///
  (line beta_block block if spec == 5 , lcolor(midblue) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if spec == 5, mlcolor(midblue) mfcolor(white)  msymbol(O) msize(medium)), /// 
  yline(0, lcolor(gs7)) scheme(fb) ///
  ylabel(10 5 0 -5 -10 -15, labsize(5)) yscale(range(10 -15) noextend)   ///
  ytitle("Energy consumption (kWh)", size(5)) xtitle("Hour of day", size(5)) ///
  legend(off) xlabel(0 4 8 12 16 20 24, valuelabel  labsize(5)) xscale(range(0 23) noextend)
graph export "$dirpath_results_final/fig_blockwise_dd_levels_binary.pdf", replace


/*
twoway ///
  (rspike ci95_lo ci95_hi blockplus1 if spec == 1 , lcolor(gs12) lwidth(thin) lpattern(solid)) ///
  (line beta_block blockplus1 if spec == 1 , lcolor(midblue*0.2) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block blockplus1 if spec == 1 , mlcolor(midblue*0.2) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (rspike ci95_lo ci95_hi block if spec == 5 , lcolor(gs12) lwidth(thin) lpattern(solid)) ///
  (line beta_block block if spec == 5 , lcolor(midblue) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if spec == 5, mlcolor(midblue) mfcolor(white)  msymbol(O) msize(medium)), /// 
  yline(0, lcolor(gs7)) scheme(fb) ///
  ylabel(5 0 -5 -10, labsize(5)) yscale(range(5 -10))   ///
  ytitle("Energy consumption (kWh)", size(5)) xtitle("") ///
  legend(off) xlabel(1 "Midn. to 3 AM" 2 "3 AM to 6 AM" 3 "6 AM to 9 AM" ///
  4 "9 AM to Noon" 5 "Noon to 3 PM" 6 "3 PM to 6 PM" /// 
  7 "6 PM to 9 PM" 8 "9 PM to Midn.", valuelabel angle(45) labsize(4))
graph export "$dirpath_results_final/fig_blockwise_dd_levels_binary.pdf", replace
*/

}
}



************************************************
************************************************


******* FIGURE: MACHINE LEARNING RESULTS BY HOUR-BLOCK (BINARY, LEVELS -- MULTIPLE ESTIMATORS)
{
** PREP DATA
{
local dataset = "_by_block"

use "$dirpath_data_int/RESULTS_monthly_block.dta", clear
replace spec = spec-1

forvalues i = 1/8 {
  replace ci95_lo_block`i' = beta_block`i' - 1.96 * se_block`i'
  replace ci95_hi_block`i' = beta_block`i' + 1.96 * se_block`i'
}


drop if spec == .
drop if beta_block1 == .

keep beta_block* ci95_lo* ci95_hi* spec yvar

reshape long beta_block ci95_lo_block ci95_hi_block, i(yvar spec) j(block)

replace block = block - 1

label define blocklab 0 "Average" 1 "Midn. to 3 AM" 2 "3 AM to 6 AM" 3 "6 AM to 9 AM" ///
  4 "9 AM to Noon" 5 "Noon to 3 PM" 6 "3 PM to 6 PM" /// 
  7 "6 PM to 9 PM" 8 "9 PM to Midn."
  
label values block blocklab   
gen blockplus1 = block -0.1

}

** MAKE FIGURES
{
forvalues s = 1/5 {
twoway ///
  (line beta_block block if spec == `s' & yvar == "prediction_error1", lcolor(midblue*0.1) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if  spec == `s' & yvar == "prediction_error1", mlcolor(midblue*0.1) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (line beta_block block if spec == `s' & yvar == "prediction_error2", lcolor(midblue*0.3) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if spec == `s' & yvar == "prediction_error2", mlcolor(midblue*0.3) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (line beta_block block if spec == `s' & yvar == "prediction_error3", lcolor(midblue*0.5) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if spec == `s' & yvar == "prediction_error3", mlcolor(midblue*0.5) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (line beta_block block if spec == `s' & yvar == "prediction_error4", lcolor(midblue*0.7) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if spec == `s' & yvar == "prediction_error4", mlcolor(midblue*0.7) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (line beta_block block if  spec == `s' & yvar == "prediction_error7", lcolor(midblue*1.2) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if  spec == `s' & yvar == "prediction_error7", mlcolor(midblue*0.9) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (line beta_block block if spec == `s' & yvar == "prediction_error8", lcolor(midblue*1.4) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if  spec == `s' & yvar == "prediction_error8", mlcolor(midblue*1.2) mfcolor(white)  msymbol(O) msize(medium)) /// 
  (line beta_block block if spec == `s' & yvar == "qkw_hour", lcolor(gs7) lwidth(medthick) lpattern(solid)) ///
  (scatter beta_block block if  spec == `s' & yvar == "qkw_hour", mlcolor(gs7) mfcolor(white)  msymbol(O) msize(medium) /// 
  text(5 -4 "`s'", color(black) size(huge))) , /// 
  yline(0, lcolor(gs7)) scheme(fb) ///
  ylabel(5 0 -5 -10, labsize(5)) yscale(range(5 -10) noextend)   ///
  ytitle("Prediction error (kWh)", size(5)) xtitle("Hour of day", size(5)) ///
  legend(off) xlabel(0 4 8 12 16 20 24,  labsize(5)) xscale(range(0 23) noextend)
  graph export "$dirpath_results_final/Appendix/fig_blockwise_ml_levels_binary_mlalternatives_spec`s'.pdf", replace

  
/*
  ylabel(5 0 -5 -10, labsize(5)) yscale(range(5 -10))   ///
  ytitle("Prediction error (kWh)", size(5)) xtitle("") ///
  legend(off) xlabel(1 "Midn. to 3 AM" 2 "3 AM to 6 AM" 3 "6 AM to 9 AM" ///
  4 "9 AM to Noon" 5 "Noon to 3 PM" 6 "3 PM to 6 PM" /// 
  7 "6 PM to 9 PM" 8 "9 PM to Midn.", valuelabel angle(45) labsize(4))
*/

}




}
/*
twoway (line beta_block spec if treattype == "", lcolor(gs7) lpattern(solid) lwidth(medthick)) ///
       (line beta_block spec if treattype == "", lcolor(gs7) lpattern(solid) lwidth(medthick)), ///
   scheme(fb) xscale(off) yscale(off)  ///
  legend(order(1 "Panel FE") position(6) rows(1) symxsize(10))
graph export "$dirpath_results_final/fig_legend_pfe.pdf", replace
*/
}



************************************************
************************************************


******* FIGURE: MACHINE LEARNING INTUITION
{
** PREP DATA
{

clear
set obs 1000
set seed 12345

gen y = 0.5*cos(0.05*_n) + 0.1*rnormal() + 30 
gen time = _n

gen ypred = y + 0.1*rnormal() 

gen ytreatment = y
replace ytreatment = y - 0.75 if time > 500
}

** MAKE FIGURE
{

twoway ///
       (scatter ytreatment time, mcolor(gs13) msize(vsmall)) ///
       (line ypred time if time <= 500, lcolor(midblue*0.5) lpattern(solid) lwidth(thin)) ///
       (line ypred time if time > 500, lcolor(midblue) lpattern(solid) lwidth(thin)) ///
	   , ///
 xtitle("Time") ytitle("Energy consumption (kWh)") yscale(range(28 31)) ylab(28(1)31) /// 
 legend(position(6) rows(1) order(2 "In-sample prediction" 3 "Out-of-sample prediction" 1 "Data" ) region(lcolor(white)))
 
 graph export "$dirpath_results_final/fake_ml_intuition_paper.pdf", replace
}
}

************************************************
************************************************


************************************************
************************************************
********** REVISION
************************************************
************************************************




************************************************
************************************************

******* FIGURE: KDENSITIES (MONTHLY TEMP)
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", clear
replace yvar = "qkw_temp" if yvar=="qkw_hour"
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if yvar == "qkw_hour" | yvar == "prediction_error4" | yvar == "qkw_temp"
keep if strpos(xvar, "davis binary")
gen rate = beta_aggregate / davis_denominator
}

drop if spec==1
** MAKE FIGURES
{

twoway ///
   (kdensity rate if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity rate if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity rate if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_rate_monthlyt.pdf", replace


twoway ///
   (kdensity beta if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity beta if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity beta if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("Energy use (kWh)") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_betas_monthlyt.pdf", replace

preserve
keep if spec==5 | spec==6
twoway ///
   (kdensity rate if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity rate if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity rate if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_rate_spec5_monthlyt.pdf", replace


twoway ///
   (kdensity beta if yvar == "qkw_hour", lpattern(dash) lcolor(gs10)) ///
   (kdensity beta if yvar == "qkw_temp", lpattern(solid) lcolor(eltblue)) ///
   (kdensity beta if yvar == "prediction_error4", lpattern(solid) lcolor(midblue)), ///
  ytitle("", size(4)) xtitle("") title("") ///
  legend(order(1 "Panel fixed effects" 2 "Panel with hourly temperature" 3 "Machine learning") position(6)) ///
    yscale(off noextend) xscale(noextend) ///
  scheme(fb)
graph export "$dirpath_results_final/fig_kdensities_betas_spec5_monthlyt.pdf", replace
restore

}

}
























******* FIGURE: SCHOOL-SPECIFIC EFFECTS (EMPIRICAL BAYES)
{
use "$dirpath_data_int/school_specific_slopes_flagged_robust.dta", clear

* merge in data
merge m:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_int/School specific/cdscode_samplesize.dta", keep(3) nogen
merge m:1 cds_code using "$dirpath_data_temp/demographics_for_selection_regs.dta", keep(3)

* savings variables
gen savings = -tot_kwh/(365*24)

cd "$dirpath_results_prelim"


local beta_pick = "ebayes"

summ `beta_pick' if savings != 0, det
local l_thr_beta = -r(p99)
local u_thr_beta = -r(p1)

summ `beta_pick' if savings == 0, det
local l_thr_beta0 = -r(p99)
local u_thr_beta0 = -r(p1)

summ savings if savings != 0, det
local l_thr_sav = -r(p99)
local u_thr_sav = -r(p1)

replace savings = -savings
replace `beta_pick' = -`beta_pick'

reg `beta_pick' savings [w=numobs]
reg `beta_pick' savings [w=numobs] if savings < `u_thr_sav'
reg `beta_pick' savings [w=numobs] if savings < `u_thr_sav' & savings > `l_thr_sav'
reg `beta_pick' savings [w=numobs] if `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta' & savings < `u_thr_sav' & savings > `l_thr_sav'
local slope_sav = round(_b[savings],.01)


twoway (scatter  `beta_pick' savings, mcolor(gs10))  ///
		(pci 41 40 41 40, lcolor(gs12) lwidth(thin) ///
		text(48 46 "Slope:", size(7)) text(38 46 "`slope_sav'", size(7)) text(75 -8.5 "A", size(vhuge))) ///	
        (lfit `beta_pick' savings [w=numobs] , lcolor(midblue) lstyle(solid) lwidth(medthick))  ///	
		if `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta' & savings < `u_thr_sav' & savings > `l_thr_sav', graphregion(color(white))  ///
		legend(off) scheme(fb) xtitle("Expected savings (kWh)", size(7)) ytitle("Estimated savings (kWh)", size(7)) ///
		yscale(range(-75 75) noextend) xscale(noextend) ylab(-75 -50 -25 0 25 50 75, labsize(7)) xlab(, labsize(7)) yline(0, lcolor(gs7) lwidth(thin)) ///
		saving("$dirpath_results_prelim/heterogeneous_betas_lfit_eb_text.gph", replace)

		
twoway (kdensity `beta_pick' [w=numobs] if savings==0 & `beta_pick' < `u_thr_beta0' & `beta_pick' > `l_thr_beta0', horizontal lcolor(gs12) lstyle(solid) lwidth(medium)) ///
	(kdensity `beta_pick' [w=numobs] if savings > 0  & `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta', horizontal lcolor(midblue) lstyle(solid) lwidth(medium) ///
	text(75 -0.04 "B", size(vhuge))) ///
	, scheme(fb) legend(off) ytitle("") xtitle("Density", color(white)) ///
	xla(,tlength(0) labcolor(white) labsize(7)) xscale(lcolor(white)) ///
	yscale(range(-75 75) noextend) ylab(-75 -50 -25 0 25 50 75, labsize(7)) ///
	 yline(0, lcolor(gs7) lwidth(thin)) ///
		saving("$dirpath_results_prelim/heterogeneous_betas_distribution_eb.gph", replace)

** graph combine
graph combine "$dirpath_results_prelim/heterogeneous_betas_lfit_eb_text.gph" "$dirpath_results_prelim/heterogeneous_betas_distribution_eb.gph", ///
       rows(1)    ///
	   scheme(fb) ysize(4) xsize(10) ///
      saving(heterogeneous_betas_eb_combo, replace)
graph export "$dirpath_results_final/fig_school_specific_EB.pdf", replace as(pdf)

}





******* FIGURE: MAKE ENERGY EFFICIENCY SUMMARY STATISTICS
{
use "$dirpath_data_int/ee_clean_elec_noclusters.dta", clear

gen counter = 1

collapse (sum) counter adj, by(upgrade date)

gen year = year(date)
gen month = month(date)
gen ym = ym(year, month)
format ym %tm


collapse(sum) counter adj, by(ym year month upgrade)

preserve
keep counter  ym
collapse (sum) counter, by(ym)

rename counter total_count

tempfile total1
save `total1'

restore

merge m:1 ym using `total1', nogen

preserve
keep adj ym
collapse (sum) adj, by(ym)
rename adj total_kwh

tempfile total2
save `total2'

restore
merge m:1 ym using `total2', nogen 

keep if year > 2007 & year < 2015


twoway (line total_count ym if upgrade == 7, lpattern(solid) lcolor(navy)) ///
       (line counter ym if upgrade == 7, lpattern(solid) lcolor(midblue)) ///
       (line counter ym if upgrade == 8, lpattern(solid) lcolor(eltblue) ///
        text(250 565 "A", color(black) size(huge))), ///
	   ytitle("Number of upgrades") xtitle("") ///
	   legend(order(1 "Total" 2 "HVAC" 3 "Lighting"))
graph export "$dirpath_results_final/fig_eestats_A.pdf", replace
	   
	   	   
use "$dirpath_data_int/ee_clean_elec_noclusters.dta", clear

gen  year = year(date)
keep if year > 2007 & year < 2015

drop if upgrade_tech == 11
gen counter = 1
collapse (sum) counter adj, by(upgrade)

gsort -adj
gen back = _n

format adj %30.0f

gen adj2 = adj / 1000


format adj2 %8.0fc  
graph twoway (bar adj2 back, horizontal barwidth(0.8) fcolor(gs10) lcolor(gs10) ///
        text(10.5 -12000 "B", color(black) size(huge))), ///
     ylabel(1 "Lighting" 2 "HVAC" ///
     3 "Electronics" 4 "Cross portfolio" 5 "Appliances" 6 "Refrigeration" ///
	 7 "Food service" 8 "Boilers" 9 "Motors" 10 "     Building envelope") ///
	 ytitle("") ylabel(,noticks) ///
	 xtitle("Expected savings ('000 kWh)")
graph export "$dirpath_results_final/fig_eestats_B.pdf", replace
}
	 
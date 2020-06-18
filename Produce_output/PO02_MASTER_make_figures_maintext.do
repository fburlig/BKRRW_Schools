************************************************
**** PRODUCE OUTPUT: MAKE MAIN TEXT FIGURES
************************************************

** Figure 1: Energy efficiency upgrades
{
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

{
** Merge electricity data with school EE data
use "$dirpath_data_temp/ee_build_dataset_appended_AUGUST_nov5.dta", clear
append using "$dirpath_data_temp/ee_build_dataset_appended_AUGUST_OLDDATA.dta"
duplicates drop
* merge in the school identifiers
merge m:1 sp_id using "$dirpath_data_int/pge_lea_meter_crosswalk_oct2016.dta"
* only keep upgrades that merged (there are lots of 1's because
  * this dataset of ee upgrades comes from 3 PG&E data pulls
tab _merge
keep if _merge == 3
drop _merge
unique cds_code

gen per_unit = adj_gross_kwh / units

gen counter = 1
keep measure_code technology_fam technology product_name project_life per_unit counter upgrade_tech_fam

collapse (sum) counter, by(measure_code technology_fam technology product_name upgrade_tech_fam project_life per_unit)

drop if upgrade_tech_fam == 11

decode upgrade_tech_fam, gen(utf)

gen rank = .
replace rank = 1 if utf == "BUILDING ENVELOPE"
replace rank = 2 if utf == "MOTORS, PUMPS, FANS"
replace rank = 3 if utf == "BOILERS AND STEAM SYSTEMS"
replace rank = 4 if utf == "FOOD SERVICE TECHNOLOGY"
replace rank = 5 if utf == "REFRIGERATION"
replace rank = 6 if utf == "APPLIANCES"
replace rank = 7 if utf == "CROSS PORTFOLIO"
replace rank = 8 if utf == "ELECTRONICS AND IT"
replace rank = 9 if utf == "HVAC"
replace rank = 10 if utf == "LIGHTING"

la define ranklab 1 "Building envelope" 2 "Motors" 3 "Boilers" ///
     4 "Food service" 5 "Refrigeration" 6 "Appliances" 7 "Cross portfolio" ///
	 8 "Electronics" 9 "HVAC" 10 "Lighting"
	 
la values rank ranklab

graph hbox per_unit [fweight = counter], over(rank)  noout ///
 ylab(,nogrid) ytitle("Expected savings (kWh)") subtitle("") note(" ")  ///
 box(1 ,fcolor(gs10) lcolor(gs10)) ///
 text(-1500 105 "C", size(huge))

graph export "$dirpath_results_final/fig_eestats_C.pdf", replace
}


******* FIGURE: EXPECTED SAVINGS RELATIVE TO CONSUMPTION
{
use "$dirpath_data_temp/monthly_by_block4_sample0.dta", clear
keep cds_code
duplicates drop
merge 1:1 cds_code using "$dirpath_data_int/data_for_selection_table.dta", keep(3)
keep if _treatmerge == 3
merge 1:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(1 3) nogen
merge 1:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
merge 1:1 cds_code using "$dirpath_data_temp/cds_coastal.dta", keep(1 3) nogen

gen proj_sav_pct = tot_kwh/(mean_energy_use*24*365)

twoway (hist proj_sav_pct, fc(gs12) lc(gs13) lw(thin) freq ///
 text(400 -0.15 "D", size(huge)))  ///
 if proj_sav_pct != 0 & proj_sav_pct != . & proj_sav_pct < 1 , ///
	 legend(off) ///
	 xscale(range(0 1)) xlab(0(0.2)1) ///
	scheme(fb) ytitle("Number of schools") xtitle("Expected savings as a share of average electricity consumption")	
	
graph export "$dirpath_results_final/fig_eestats_D.pdf", as(pdf) replace

}
}

** Figure 2: School characteristics before and after treatment
{
** PREP DATA
{

use "$dirpath_data_int/RESULTS_demographic_eventstudies.dta", clear

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

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Number of students") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_enrtotal.pdf", replace


local outcome "staff_count"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Number of staff") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_stafftotal.pdf", replace


local outcome "mathproficient"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Percent of students proficient or better (math tests)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_mathproficient.pdf", replace



local outcome "elaproficient"
local spec 2

twoway (rspike ci95_lo ci95_hi esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(gs10) lwidth(medium)) ///
       (line beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3, lcolor(midblue) lwidth(medium) lpattern(solid)) ///
       (scatter beta esyr if spec == `spec' & yvar == "`outcome'" & esyr < 5 & esyr > -3 , mlcolor(midblue) mfcolor(white) msize(medium) ///
       text(4 -7.75 , color(black) size(huge))) , /// 
	   scheme(fb) ytitle("Percent of students proficient or better (ELA tests)") /// 
	   xtitle("Years to upgrade") legend(off) yline(0, lcolor(gs12)) ///
	   xlabel(-2 0 2 4) /* ylabel(-6(2)4) yscale(range(-6 4)) */

graph export "$dirpath_results_final/fig_eventstudy_demographics_elaproficient.pdf", replace

}



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

** Figure 3: Machine learning diagnostics
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

** Figure 4: Comparison of methods across specifications and samples
{
** PREP DATA
{
use "$dirpath_data_int/RESULTS_monthly_wtemperature.dta", clear
replace yvar = "qkw_temp" if yvar=="qkw_hour"
gen rate = beta_aggregate / davis_denominator
append using "$dirpath_data_int/RESULTS_monthly.dta"
keep if yvar == "qkw_hour" | yvar == "prediction_error4" | yvar == "qkw_temp"
drop if yvar == "prediction_error4" & postctrls == ""
drop if yvar != "prediction_error4" & postctrls == "post"
keep if strpos(xvar, "davis binary")

drop if spec == 1
}

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

}

}

** Figure 5: School-specific effects
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

reg `beta_pick' savings
reg `beta_pick' savings if savings < `u_thr_sav'
reg `beta_pick' savings if savings < `u_thr_sav' & savings > `l_thr_sav'
reg `beta_pick' savings if `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta' & savings < `u_thr_sav' & savings > `l_thr_sav'
local slope_sav = round(_b[savings],.01)


twoway (scatter  `beta_pick' savings, mcolor(gs10))  ///
		(pci 41 40 41 40, lcolor(gs12) lwidth(thin) ///
		text(48 46 "Slope:", size(7)) text(38 46 "0`slope_sav'", size(7)) text(75 -8.5 "A", size(vhuge))) ///	
        (lfit `beta_pick' savings  , lcolor(midblue) lstyle(solid) lwidth(medthick))  ///	
		if `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta' & savings < `u_thr_sav' & savings > `l_thr_sav', graphregion(color(white))  ///
		legend(off) scheme(fb) xtitle("Expected savings (kWh)", size(7)) ytitle("Estimated savings (kWh)", size(7)) ///
		yscale(range(-75 75) noextend) xscale(noextend) ylab(-75 -50 -25 0 25 50 75, labsize(7)) xlab(, labsize(7)) yline(0, lcolor(gs7) lwidth(thin)) ///
		saving("$dirpath_results_prelim/heterogeneous_betas_lfit_eb_text.gph", replace)

		
twoway (kdensity `beta_pick' if savings==0 & `beta_pick' < `u_thr_beta0' & `beta_pick' > `l_thr_beta0', horizontal lcolor(gs12) lstyle(solid) lwidth(medium)) ///
	(kdensity `beta_pick'  if savings > 0  & `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta', horizontal lcolor(midblue) lstyle(solid) lwidth(medium) ///
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

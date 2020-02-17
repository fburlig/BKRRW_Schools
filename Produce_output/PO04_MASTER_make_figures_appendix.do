************************************************
**** PRODUCE OUTPUT: MAKE APPENDIX FIGURES
************************************************

** Figure A.1: Comparing machine learning estimators
{
use "$dirpath_data_int/RESULTS_ml_estimators_levels_samples.dta", clear

keep if subsample=="0"
keep if yvar == "prediction_error4"

gen spec = .
replace spec = 1 if spec_desc == "bc"
replace spec = 2 if spec_desc == "bt"
replace spec = 3 if spec_desc == "bdd"
replace spec = 4 if spec_desc == "bcd"
replace spec = 5 if spec_desc == "btd"
replace spec = 6 if spec_desc == "b3d"

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

** Figure B.1: Machine learning results by hour (alternative prediction methods)
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

 
}
}
}

** Figure B.2: School-specific effects from double machine learning
{
use "$dirpath_data_int/RESULTS_schools_effects_dl.dta", clear

* merge in data
merge 1:1 cds_code using "$dirpath_data_int/ee_total_formerge.dta", keep(3) nogen
merge 1:1 cds_code using "$dirpath_data_temp/mean_energy_use.dta", keep(3) nogen
merge 1:1 cds_code using "$dirpath_data_int/School specific/cdscode_samplesize.dta", keep(3) nogen
merge 1:1 cds_code using "$dirpath_data_temp/demographics_for_selection_regs.dta", keep(3)

* savings variables
gen savings = -tot_kwh/(365*24)

cd "$dirpath_results_prelim"


local beta_pick = "theta"

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
		saving("$dirpath_results_prelim/heterogeneous_betas_lfit_dl_text.gph", replace)

		
twoway (kdensity `beta_pick' if savings==0 & `beta_pick' < `u_thr_beta0' & `beta_pick' > `l_thr_beta0', horizontal lcolor(gs12) lstyle(solid) lwidth(medium)) ///
	(kdensity `beta_pick'  if savings > 0  & `beta_pick' < `u_thr_beta' & `beta_pick' > `l_thr_beta', horizontal lcolor(midblue) lstyle(solid) lwidth(medium) ///
	text(75 -0.04 "B", size(vhuge))) ///
	, scheme(fb) legend(off) ytitle("") xtitle("Density", color(white)) ///
	xla(,tlength(0) labcolor(white) labsize(7)) xscale(lcolor(white)) ///
	yscale(range(-75 75) noextend) ylab(-75 -50 -25 0 25 50 75, labsize(7)) ///
	 yline(0, lcolor(gs7) lwidth(thin)) ///
		saving("$dirpath_results_prelim/heterogeneous_betas_distribution_dl.gph", replace)

** graph combine
graph combine "$dirpath_results_prelim/heterogeneous_betas_lfit_dl_text.gph" "$dirpath_results_prelim/heterogeneous_betas_distribution_dl.gph", ///
       rows(1)    ///
	   scheme(fb) ysize(4) xsize(10) ///
      saving(heterogeneous_betas_eb_combo, replace)
graph export "$dirpath_results_final/fig_school_specific_DL.pdf", replace as(pdf)
}

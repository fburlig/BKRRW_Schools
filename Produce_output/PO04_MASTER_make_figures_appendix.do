************************************************
**** PRODUCE OUTPUT: MAKE APPENDIX FIGURES
************************************************

** Figure A.1: Comparing machine learning estimators
{
use "$dirpath_data_int/RESULTS_ml_estimators_levels_samples.dta", clear

keep if subsample=="0"

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

keep if subsample == "0"
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

** Figure B.2: Machine learning results by hour (alternative prediction methods)
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

** Figure B.4: Energy efficiency upgrades
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

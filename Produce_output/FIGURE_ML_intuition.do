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

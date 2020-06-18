* Double lasso

use "$dirpath_data_temp/full_blocks_any_newpred_by_block.dta", clear

* generate ols for each of the splits
gen numerator = prediction_error9 * prediction_treat_error9
gen denominator = prediction_treat_error9^2

collapse (mean) numerator denominator (max) any_post_treat , by(cds_code  splitting )
  
gen theta = numerator/denominator
 
* average theta across slpits
collapse (mean) theta any_post_treat, by(cds_code)
 
* distribution of results
twoway (kdensity theta if any==0) (kdensity theta if any==1)

* saving outcomes 
save "$dirpath_data_int/RESULTS_schools_effects_dl.dta", replace

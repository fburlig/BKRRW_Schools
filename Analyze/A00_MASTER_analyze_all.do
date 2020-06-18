************************************************
**** MASTER ANALYSIS FILE (CALLS ALL ANALYSIS FILES)
************************************************

*** Perform analysis for summary statistics table
do "$dirpath_code_analyze/A01_MASTER_summary_stats_table.do"
 
*** Perform analysis for school characteristics event study figure -- schools
do "$dirpath_code_analyze/A02_MASTER_main_demographic_regressions_event.do"
 
*** Perform analysis for school characteristics event study figure -- energy
do "$dirpath_code_analyze/A03_MASTER_main_monthly_regressions_event_yearly_BP.do"
 
*** Run main monthly regressions
do "$dirpath_code_analyze/A04_MASTER_main_monthly_regressions.do"

*** Run main monthly regressions, with temperature controls
do "$dirpath_code_analyze/A05_MASTER_main_monthly_regressions_temperature.do"
 
*** Run main monthly regressions, with bootstraps (ML)
do "$dirpath_code_analyze/A06_MASTER_main_monthly_regressions_bootstrap.do"
  
*** Run main monthly regressions, double lasso (ML)
do "$dirpath_code_analyze/A07_MASTER_main_monthly_regressions_dl.do"
  
*** Run main monthly regressions, donuts
do "$dirpath_code_analyze/A08_MASTER_main_monthly_regressions_donuts.do"
 
*** Run main monthly regressions, donuts for savings estimates
do "$dirpath_code_analyze/A09_MASTER_main_monthly_regressions_savings_donuts.do"
 
*** Run main monthly regressions, donuts for savings estimates
do "$dirpath_code_analyze/A10_MASTER_main_monthly_regressions_savings_donuts.do"
 
*** Run main monthly regressions, hour-of-day-specific effects
do "$dirpath_code_analyze/A11_main_monthly_regressions_hourly.do"
 
*** Run main monthly regressions, hour-of-day-specific effects (DL)
do "$dirpath_code_analyze/A12_main_monthly_regressions_hourly.do"
 
*** Run main monthly regressions, matched samples
do "$dirpath_code_analyze/A13_main_monthly_regressions_matching.do"
 
*** Run main monthly regressions, school-specific slopes for empirical Bayes
do "$dirpath_code_analyze/A14_MASTER_empirical_bayes_singletons_cluster.do"

*** Run heterogeneity analysis with empirical Bayes shrinkage
do "$dirpath_code_analyze/A15_MASTER_heterogeneity_analysis_monthlydata_empiricalbayes.do"
 
*** Run main monthly regressions, with heterogeneity by bond status
do "$dirpath_code_analyze/A16_MASTER_main_monthly_regressions_bonds.do"
 
*** Run main hourly regressions, including temperature controls
do "$dirpath_code_analyze/A17_MASTER_main_hourly_regressions_temperature.do"
 
*** Run main hourly regressions, not including temperature controls
do "$dirpath_code_analyze/A18_MASTER_main_hourly_regressions_notemperature.do"
 
*** Produce double lasso distributions
do "$dirpath_code_analyze/A19_MASTER_dml_schools.do"

*** Compute out-of-sample $R^2$ of different ML algorithms
do "$dirpath_code_analyze/A20_MASTER_main_predictions_r2.do"
 
*** Compute treatment effects for different ML estimators
do "$dirpath_code_analyze/A21_MASTER_mlestimators.do"

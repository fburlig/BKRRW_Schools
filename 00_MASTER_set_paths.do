************************************************
**** MASTER SETUP
************************************************

************************************************
**** SETUP:
clear all
set more off, perm
set type double
version 12

set seed 12345

** CHANGE TO YOUR DIRECTORY PATH
global dirpath "T:/Projects/Schools"

** Code paths
global dirpath_code "$dirpath/BKKRW_Schools"
global dirpath_code_build "$dirpath_code/Build"
global dirpath_code_analyze "$dirpath_code/Analyze"

** Data paths
global dirpath_data "$dirpath/Data"
global dirpath_data_raw "$dirpath/Data/Raw"
global dirpath_data_int "$dirpath/Data/Intermediate"
global dirpath_data_final "$dirpath/Data/Final"
global dirpath_data_temp "$dirpath/Data/Temp"
global dirpath_data_other "$dirpath/Data/Other data"

** Results paths
global dirpath_results_prelim "$dirpath/Results/Preliminary"
************************************************

************************************************
** Required programs:
/*
 -- unique
 -- geonear
 -- gsort
 -- reghdfe

*/
************************************************

****************************************************************
**** MASTER PRODUCE OUTPUT FILE (CALLS ALL PRODUCE OUTPUT FILES)
****************************************************************

*** Produce main text tables
do "$dirpath_code_output/PO01_MASTER_make_tables_maintext.do"

*** Produce main text figures
do "$dirpath_code_output/PO02_MASTER_make_figures_maintext.do"

*** Produce appendix tables
do "$dirpath_code_output/PO03_MASTER_make_tables_appendix.do"

*** Produce appendix figures
do "$dirpath_code_output/PO04_MASTER_make_figures_appendix.do"

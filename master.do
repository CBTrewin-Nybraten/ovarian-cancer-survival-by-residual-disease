
********************************************************************************
* Code for analysis of ovarian cancer survival by residual disease status

* Analyses performed by Cassia Trewin-Nybråten
* Version 8, 17.2.2024
********************************************************************************

** Analysis file preparation: 

	* define histotype by morphology ICD03 codes
	* create variables
	* define study population
	* stset
	* merge expected mortality

do "prepare_ovca2.do"


** Tables 

do "table1.do"
do "table2.do"
do "table3.do"


** Figures 

do "figure1.do"
do "figure2.do"
do "figure3.do"



********************************************************************************
** Table 2: Excess Hazard ratios by histotype and residual disease (RD)
** Model 1: Dichotomous RD, all histotypes
** Model 2: Dichotomous RD, by histotype
** Model 3: Categorical RD, all histotypes 
********************************************************************************


use "ovca2.dta", clear 

keep if spop == 1					// Main study population
keep if opr == 1 					// Operated

drop if ( rd == 99 )				// Unknown residual disease status 

********************************************************************************

** Categorical residual disease diameter

egen rdcm_gp = cut(rdcm), at(0.1 0.5 1.0 1.1 3) label	
replace rdcm_gp = rdcm_gp + 1
replace rdcm_gp = 0 if ( rd == 1 )

lab def rdcm_gp_lab 				///
	0 "None" 						///
	1 "0.1-0.4 cm" 					///
	2 "0.5-0.9 cm" 					///
	3 "1.0 cm" 						///
	4 "1.1-2.9 cm" 					///
	5 "3.0-20.0 cm" 
lab val rdcm_gp rdcm_gp_lab


********************************************************************************
** Model 1: Dichotomous RD, all histotypes 
********************************************************************************

stpm2 i.rd i.histotype i.figo i.ecog age, 									///
			scale(hazard) df(5) bhazard(fitmx) eform 						///
			tvc(bhaz2 bhaz3 bhaz4) dftvc(2)
  
  
********************************************************************************
** Model 2: Dichotomous RD, by histotype
********************************************************************************

stpm2 i.histotype#i.rd i.histotype i.figo i.ecog age if ( histotype < 6 ), 	///
			scale(hazard) df(5) bhazard(fitmx) eform 					   	///
			tvc(bhaz2 bhaz3 bhaz4) dftvc(2)


********************************************************************************
** Model 3: Categorical RD, all histotypes 
********************************************************************************

stpm2 i.rdcm_gp i.histotype i.figo i.ecog age, 								///
			scale(hazard) df(5) bhazard(fitmx) eform 					   	///
			tvc(bhaz2 bhaz3 bhaz4) dftvc(2)


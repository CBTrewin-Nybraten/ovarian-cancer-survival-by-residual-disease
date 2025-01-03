
********************************************************************************
** Figure 2 
* (A) Histogram of residual disease diameter 
* (B) Predicted 3-year relative survival across continuous residual disease diameter
* (C) Excess hazard ratios by categorical residual disease diameter
********************************************************************************



********************************************************************************
** Figure 2A: Histogram of residual disease diameter 
********************************************************************************

use "ovca2.dta", clear 

keep if spop == 1	// Main study population
keep if opr == 1 	// Operated
keep if !mi(rdcm)	// Not missing residual disease diameter


********************************************************************************

** combine endometroid, adenocarcinoma (low/unknown grade) and other epithelial
recode histotype ( 6/8 = 6 )
lab def histotype_lab 6 "Other", modify 


** Don't show higher than 15 cm
replace rdcm = 15 if rdcm > 15 		


** Categorical residual disease diameter

egen rdcm_gp = cut(rdcm), at(0.1 0.5 1.0 1.1 3) label	
replace rdcm_gp = rdcm_gp + 1

lab def rdcm_gp_lab 				///
	1 "0.1-0.4 cm" 					///
	2 "0.5-0.9 cm" 					///
	3 "1.0 cm" 						///
	4 "1.1-2.9 cm" 					///
	5 "3.0-20.0 cm" 
lab val rdcm_gp rdcm_gp_lab


********************************************************************************

collapse (count) cases = id, by(histotype rdcm)


********************************************************************************
** Figure 2B: Predicted 3-year relative survival by continuous residual disease diameter
********************************************************************************

use "ovca2.dta", clear 

keep if spop == 1	// Main study population
keep if opr == 1 	// Operated
keep if !mi(rdcm)	// Not missing residual disease diameter


********************************************************************************

** Model log of residual disease diameter
gen logrdcm = log(rdcm)

** Time variable for prediction
gen t3 = 3


********************************************************************************
** Expand data so have one group for all histotypes and one group for HGS

gen hist2 = 1 
expand 2 if ( histotype == 1 ), gen(expanded)
replace hist2 = 2 if expanded 
 
lab def hist2_lab 		///
	1 "All histotypes" 	///
	2 "High-grade serous"
lab val hist2 hist2_lab 


********************************************************************************
*** Splines with boundary knots at 0.2 and 2 cm

rcsgen logrdcm if ( hist2 == 1 ), gen(rcs_rdcmg1) 						///
			orthog df(3) bknots(-1.6094379 .69314718) 
			
rcsgen logrdcm if ( hist2 == 2 ), gen(rcs_rdcmg2) 						///
			orthog df(3) bknots(-1.6094379 .69314718) 


********************************************************************************

** Model 1: All histotypes
stpm2 rcs_rdcmg1* i.figo i.ecog age i.h1 if ( hist2 == 1 ),				///
			scale(hazard) df(5) bhazard(fitmx) eform					///
			tvc(h1) dftvc(2)	

predict sg1, survival at(age 64 ecog 0 figo 3 h1 0) timevar(t3) ci 
testparm rcs_rdcmg1*


* Model 2: High-grade serous
stpm2 rcs_rdcmg2* i.figo i.ecog age if ( hist2 == 2 ), 					///
			scale(hazard) df(5) bhazard(fitmx) eform

predict sg2, survival at(age 64 ecog 0 figo 3) timevar(t3) ci 
testparm rcs_rdcmg2*


********************************************************************************
* Figure 2C: Excess hazard ratios by categorical residual disease diameter
********************************************************************************

** Model 1: All histotypes
stpm2 ib3.rdcm_gp i.figo i.ecog age i.histotype if ( hist2 == 1 ),		///
			scale(hazard) df(5) bhazard(fitmx) eform					///
			tvc(h1) dftvc(2)	
testparm ib3.rdcm_gp 


* Model 2: High-grade serous
stpm2 ib3.rdcm_gp i.figo i.ecog age if ( hist2 == 2 ), 					///
			scale(hazard) df(5) bhazard(fitmx) eform
testparm ib3.rdcm_gp 
			
			
* Model 3: Non high-grade serous
stpm2 ib3.rdcm_gp i.figo i.ecog age if ( hist2 == 1 & histotype != 1 ),	///
			scale(hazard) df(5) bhazard(fitmx) eform					///
			tvc(h2) dftvc(2)				
testparm ib3.rdcm_gp 
		


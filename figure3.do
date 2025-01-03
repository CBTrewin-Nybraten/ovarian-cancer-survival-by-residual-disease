
********************************************************************************
** Figure 3
* (A) Relative survival and (B) Excess hazard ratios 
* by Primary/Interval surgery and residual disease status after cytoreductive surgery
********************************************************************************

use "ovca2.dta", clear 

keep if ispop == 1		// Study population with SACT data (2019-2022)
keep if opr == 1 		// Operated

drop if inlist(ct,0,1)	// No adjuvant chemotherapy
drop if (rd == 99 ) 	// Unknown residual disease status 

********************************************************************************

** Primary surgery, no residual disease	
gen n0r0 = ( ct == 2 ) & ( rd == 1 )

** Primary surgery, residual disease	
gen n0r1 = ( ct == 2 ) & ( rd == 2 )

** Interval surgery, no residual disease	
gen n1r0 = ( ct == 1 ) & ( rd == 1 )

** Interval surgery, residual disease	
gen n1r1 = ( ct == 1 ) & ( rd == 2 )


** Combine ECOG 2-4 into single group
recode ecog (2/4 = 2)
lab def ecog_lab 				///
	0 "O: Fully active" 		///
	1 "1: Restricted activity" 	///
	2 "2-4", modify 


** Time variable for relative survival predictions
local ind = 1
foreach var of varlist n0r0 n0r1 n1r0 n1r1 {
	
	count if `var' == 1
	local n = r(N)
	gsort -`var'
	range time`ind' 0 10 `n'
	
	local ind = `ind' + 1
	
}
egen temptime = rowfirst(time*)
drop time* 


********************************************************************************
** Figure 3A: Predicted relative survival by time since surgery 
********************************************************************************

stpm2 n0r1 n1r0 n1r1 i.figo i.ecog age i.histotype, 				///
		scale(hazard) df(5) bhazard(fitmx) eform 					///
		tvc(n0r1 n1r0 n1r1) dftvc(2)
		
predict s, survival at(age 64 ecog 0 figo 3 histotype 1) 			///
		timevar(temptime) ci

		
********************************************************************************
** Figure 3B: Excess hazard ratios adjusted for
** histotype, stage, ECOG, age and adjuvant bevacizumab or PARP-inhibitors
********************************************************************************

stpm2 n0r1 n1r0 n1r1 i.figo i.ecog age i.histotype i.ct_maintenanceAdj,	/// 
		scale(hazard) df(5) bhazard(fitmx) eform 					///
		tvc(n0r1 n1r0 n1r1) dftvc(2)


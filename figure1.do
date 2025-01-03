
********************************************************************************
** Figure 1 
* (A) Relative survival and (B) Excess hazard ratios 
* by histotype and residual disease status after cytoreductive surgery
********************************************************************************

use "ovca2.dta", clear 

keep if spop == 1					// Main study population
keep if opr == 1 					// Operated

keep if inrange(histotype, 1, 5)	// HGS, LGS, Carcinosarcoma, Mucinous, Clear cell


********************************************************************************
** Time variable for relative survival predictions 

local ind = 1
foreach var of varlist hgs0 hgs1 lgs0 lgs1 car0 car1 muc0 muc1 cc0 cc1 {
	
	count if `var' == 1
	local n = r(N)
	gsort -`var'
	range time`ind' 0 10 `n'
	
	local ind = `ind' + 1
	
}
egen temptime = rowfirst(time*)
drop time* 


********************************************************************************
** Figure 1B: Excess hazard ratios 

stpm2 hgs1 lgs0 lgs1 car0 car1 muc0 muc1 cc0 cc1 i.figo i.ecog age, ///
			scale(hazard) df(5) bhazard(fitmx) 						///
			eform tvc(bhaz2 bhaz3) dftvc(2)
			
********************************************************************************
** Figure 1A: Predicted relative survival by time since surgery 

predict s, survival at(age 64 ecog 0 figo 3) timevar(temptime) ci




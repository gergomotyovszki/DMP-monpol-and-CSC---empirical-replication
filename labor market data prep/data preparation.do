* Startup
clear all
set mem 500M
capture log close
set more off, perm

* Set base folder and paths

gl base 	"D:\project\empirical replication files\labor market data prep"  //Change this to the precise folder where the current file is located
gl inputdata "${base}/data files"
gl cleandata "${base}/clean data"

cd "${base}"

***********************************
***       Appending data   	    ***
***********************************

use "${inputdata}/morg00.dta", clear

foreach x of numlist 1(1)9 {
	append using "${inputdata}/morg0`x'.dta"
}

foreach x of numlist 10(1)16 {
	append using "${inputdata}/morg`x'.dta"
}

foreach x of numlist 79(1)99 {
	append using "${inputdata}/morg`x'.dta"
}

save "${base}/morg1979-2016.dta", replace


*******************************
***  Processing data	    ***
*******************************

use "${base}/morg1979-2016.dta", clear
* Harmonizing labor force participation variable
gen emp_status=.
replace emp_status=0 if ftpt79==0 & inrange(year,1979,1988)
replace emp_status=1 if inlist(ftpt79,1,2,4) & inrange(year,1979,1988) 
replace emp_status=2 if inlist(ftpt79,3,5) & inrange(year,1979,1988) // Clarify what is Unemployed PT. For now consider this Unemp.
replace emp_status=0 if inrange(lfsr89,5,7) & inrange(year,1989,1993)
replace emp_status=1 if inrange(lfsr89,1,2) & inrange(year,1989,1993)
replace emp_status=2 if inrange(lfsr89,3,4) & inrange(year,1989,1993)
replace emp_status=0 if inrange(lfsr94,5,7) & inrange(year,1994,2016)
replace emp_status=1 if inrange(lfsr94,1,2) & inrange(year,1994,2016)
replace emp_status=2 if inrange(lfsr94,3,4) & inrange(year,1994,2016)

* Making education variables consistent
gen edu = .
replace edu = gradeat if year<=1991
replace edu = edu - 1 if gradecp == 2 & edu >= 1 & year<=1991

* Generate broad education groups
gen education=.
replace education=1 if grade92<40 // grade92<43 
replace education=2 if grade92>=40 & !missing(grade92) // grade92>=43 & !missing(grade92)
replace education=1 if gradeat<13 & year<1992 // edu<16 & year<1992
replace education=2 if gradeat>=13 & year<1992 // edu>=16 & year<1992
la define education 1 "w/o College" 2 "Some College", replace
la val education education

* Generate broad age groups
gen age_group=2
replace age_group=1 if age<35
replace age_group=3 if age>55
la define age_group 1 "Below 35" 2 "35-55" 3 "Above 55"
la val age_group age_group

* Generate collapsed races
recode race (1 = 1 "White") (2 = 2 "Black") (else = 3 "Other"), gen(race_collapsed)

* Generate indicator for married/single (there was a re-coding of marital in 1989)
/* Marital status at time of enumeration. Until 1989 Widowed Divorced and separated were grouped, however in all years, <4 is married, otherwise single. In the original data 5 is used for Never Married until 1989. */
recode marital (1 2 3 = 1 "Married") (else = 0 "Single"), gen(married)

* Harmonize state from "state" and "stfips"
tempvar state_string stfips_string state_combined
sdecode state, gen(`state_string') labonly
sdecode stfips, gen(`stfips_string') labonly
gen `state_combined' = `state_string'
replace `state_combined' = `stfips_string' if mi(state)
encode `state_combined', gen(state_combined)

* Generate combined year-month variable
egen yearmonth = concat(year intmonth), punct("M")
gen monthly = monthly(yearmonth, "YM")
format monthly %tm

* Harmonizing and aggregating industries
gen macro_industry = 1 if inrange(dind02,5,20) & year>=2000 | inlist(dind,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,28) & year<2000 
replace macro_industry = 2 if inrange(dind02,40,43) & year>=2000 | inrange(dind,41,44) & year<2000 
replace macro_industry = 3 if inlist(dind02,1,2,3,23) & year>=2000 | inlist(dind,1,2,3,29,46) & year<2000 
replace macro_industry = 4 if inlist(dind02,21,22,46) & year>=2000 | inlist(dind,32,33) & year<2000 
replace macro_industry = 5 if inrange(dind02,36,39) & year>=2000 | inlist(dind,37,45) & year<2000 
replace macro_industry = 6 if inlist(dind02,25,26,27,28,29,30.31,32,33,34,35,50) & year>=2000 | inlist(dind,24,30,34,35,36) & year<2000 
replace macro_industry = 7 if inlist(dind02,4,24) & year>=2000 | inlist(dind,4,31) & year<2000 
replace macro_industry = 8 if inlist(dind02,44,45,47,48,49) & year>=2000 | inlist(dind,38,39,40) & year<2000 
replace macro_industry = 9 if inlist(dind02,51,52) & year>=2000 | inlist(dind,51,52) & year<2000 

* Fix some obvious outliers
replace uhourse = . if uhourse<=0

* Saving temporary data for later
save "${base}/morg1979-2016_temp.dta", replace

use "${base}/morg1979-2016_temp.dta", clear
* Only using industry categories from 1 to 6
keep if inrange(macro_industry,1,6)

*********************************************
* Generating Employment and Wage variables	*
*********************************************

gen employment_rate_any_industry = 0 if inlist(emp_status,1,2) 
replace employment_rate_any_industry = 1 if emp_status==1
gen employment_rate_ed_any_ind = 0 if inlist(emp_status,1,2) & education==2
replace employment_rate_ed_any_ind = 1 if emp_status==1 & education==2
gen employment_rate_noed_any_ind = 0 if inlist(emp_status,1,2) & education==1
replace employment_rate_noed_any_ind = 1 if emp_status==1 & education==1


gen hrlwage = earnwke/uhourse //hourly wage
gen ln_hrlwage = log(hrlwage+1) //log hourly wage
gen hrlwage_ed_any_industry=hrlwage if education==2
gen hrlwage_noed_any_industry=hrlwage if education==1
gen employed_any_ed=1 if emp_status==1 & education==2
gen employed_any_noed=1 if emp_status==1 & education==1

qui forval industry = 1(1)6{
	gen employment_rate_`industry' = 0 if inlist(emp_status,1,2) & macro_industry==`industry'
	replace employment_rate_`industry' = 1 if emp_status==1 & macro_industry==`industry'
	gen share_employed_industy_`industry' = 0 if inlist(emp_status,1)
	replace share_employed_industy_`industry' = 1 if emp_status==1 & macro_industry==`industry'
	
	gen employment_rate_`industry'_ed = 0 if inlist(emp_status,1,2) & macro_industry==`industry' & education==2
	replace employment_rate_`industry'_ed = 1 if emp_status==1 & macro_industry==`industry' & education==2
	gen share_employed_industy_`industry'_ed = 0 if inlist(emp_status,1) & education==2
	replace share_employed_industy_`industry'_ed = 1 if emp_status==1 & macro_industry==`industry' & education==2
	gen employed_`industry'_ed=1 if emp_status==1 & education==2 & macro_industry==`industry'
	
	gen employment_rate_`industry'_noed = 0 if inlist(emp_status,1,2) & macro_industry==`industry' & education==1
	replace employment_rate_`industry'_noed = 1 if emp_status==1 & macro_industry==`industry' & education==1
	gen share_employed_industy_`industry'_noed = 0 if inlist(emp_status,1) & education==1
	replace share_employed_industy_`industry'_noed = 1 if emp_status==1 & macro_industry==`industry' & education==1
	gen employed_`industry'_noed=1 if emp_status==1 & education==1 & macro_industry==`industry'
	
	gen hrlwage_ed_industry_`industry'=hrlwage if macro_industry==`industry' & education==2
	gen hrlwage_noed_industry_`industry'=hrlwage if macro_industry==`industry' & education==1	
	
}

* Calculating fitted residuals of log hourly wage for skilled and unskilled workers
forval g=1/2 {
	qui reg ln_hrlwage i.age_group i.sex i.race_collapsed i.married i.state_combined if education == `g' [pweight=earnwt]

	predict yhat_education`g' if e(sample), xb
	predict uhat_education`g' if e(sample), residual
}

rename uhat_education1 uhat_education_unskilled
rename uhat_education2 uhat_education_skilled

label var uhat_education_unskilled "Fitted residuals unskilled"
label var uhat_education_skilled "Fitted residuals skilled"

collapse (sum) employed_* (mean) year intmonth employment_rate* share_employed_industy_* hrlwage_ed* hrlwage_noed* uhat_education_unskilled uhat_education_skilled [pweight=earnwt], by(yearmonth)
sort year intmonth

gen employment_ratio=employed_any_ed/employed_any_noed
qui forval industry = 1(1)6{
	gen employment_ratio_industry_`industry'=employed_`industry'_ed/employed_`industry'_noed
}

drop year intmonth
sencode yearmonth,replace 
keep yearmonth employment_ratio* employment_rate* share_employed_industy_* hrlwage_* uhat_education_*

save "${cleandata}/morg1979-2016_final.dta", replace
export excel using "${cleandata}/morg1979_2016_final.xlsx", firstrow(variables) keepcellfmt replace 

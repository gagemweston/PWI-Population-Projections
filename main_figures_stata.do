clear all
set more off
* insert your own current directory below
cd "/Users/gageweston/Desktop/github"

cap log close
log using Spike_projections, smcl replace
import delimited main_output.csv, clear

** Abstract facts

sum year if tfr_scenario == "1.5"&population<2000000000&age=="all ages"
sum year if tfr_scenario == "1.2"&population<2000000000&age=="all ages"
sum year if tfr_scenario == "1.5"&population<1000000000&age=="all ages"
sum year if tfr_scenario == "1.2"&population<1000000000&age=="all ages"

* Use 1000 for whole world age group
replace age = "1000" if age == "all ages"
destring age, replace

local list
foreach var in fertility life_exp population births births_cum {
rename `var' `var'_
local list `list' `var'_
}
egen j = group(tfr year)
reshape wide `list', i(j) j(age)
drop j
rename population_1000 population
rename births_1000 births

count

local youth
foreach y in 0 5 10{
local youth `youth' population_`y'
}

local middle
forvalues y = 15(5)60{
local middle `middle' population_`y'
}

local old
forvalues y = 65(5)100{
local old `old' population_`y'
}

foreach age in youth middle old{
egen population_`age' = rowtotal(``age'')
}

gen dependency_total = 100*(population_youth + population_old)/population_middle
gen dependency_youth = 100*(population_youth)/population_middle
gen dependency_old = 100*(population_old)/population_middle

gen tfr = tfr_scenario if tfr_s != "replacement"
replace tfr = "2.05" if tfr == ""
destring tfr, replace

egen tag_tfr = tag(tfr)

order tfr year population births population_youth population_old population_middle dependency_*


foreach value in 5000000000 2000000000 1000000000 500000000 200000000 100000000 50000000 20000000 10000000 {
gen yr_size_`value' = .
foreach tfr in 1 1.1 1.2 1.3 1.4 1.5 1.6 1.66 1.7 1.8 1.84 1.9 2 2.05 2.1 2.2 {
sum year if tfr ==`tfr' & population <=`value'
replace yr_size_`value' = r(min) if tag_tfr == 1 & tfr == `tfr'
}
}

foreach value in 50000000 20000000 10000000 5000000 2000000 1000000 500000 200000 100000 {
gen yr_births_`value' = .
foreach tfr in 1 1.1 1.2 1.3 1.4 1.5 1.6 1.66 1.7 1.8 1.84 1.9 2 2.05 2.1 2.2 {
sum year if tfr ==`tfr' & births/5 <=`value'
replace yr_births_`value' = r(min) if tag_tfr == 1 & tfr == `tfr'
}
}

# delimit ;
twoway

(connected yr_size_50000000 tfr if yr_size_50000000 <2800, ms(i) lw(medthick) lc(navy) lp(solid))
(connected yr_size_100000000 tfr if yr_size_100000000 <2800, ms(i) lw(medthick) lc(forest_green) lp(longdash))
(connected yr_size_500000000 tfr if yr_size_500000000 <2800, ms(i) lw(medthick) lc(dkorange) lp(dash))
(connected yr_size_1000000000 tfr if yr_size_1000000000 <2800, ms(i) lw(medthick) lc(maroon) lp(shortdash))
if tfr < 2&tag_tfr==1
,
name(years_size, replace)
xtitle("asymptotic global total fertility rate")
ytitle("year in which global population size falls below level")
graphr(lc(white) c(white))
ylab(,angle(horizontal) nogrid)
ysc(log)
legend(col(1) pos(3) order(
1 "{bf:50,000,000}"
- "(≈ 2023 Colombia or South Korea)"
2 "{bf:100,000,000}"
- "(≈ 2023 Vietnam or Egypt)"
3 "{bf:500,000,000}"
- "(≈ 2023 European Union)"
4 "{bf:1,000,000,000}"
- "(≈ 2023 sub-Saharan Africa)"
))
xsize(12) ysize(6)
;
#delimit cr

graph save years_size "years_size.gph", replace
graph export "years_size.pdf", as(pdf) replace

#delimit ;
twoway

(connected yr_births_200000 tfr if yr_births_200000 <2800, ms(i) lw(medthick) lc(navy) lp(solid))
(connected yr_births_2000000 tfr if yr_births_2000000 <2800, ms(i) lw(medthick) lc(forest_green) lp(longdash))
(connected yr_births_10000000 tfr if yr_births_10000000 <2800, ms(i) lw(medthick) lc(dkorange) lp(dash))
(connected yr_births_20000000 tfr if yr_births_20000000 <2800, ms(i) lw(medthick) lc(maroon) lp(shortdash))

if tfr < 2&tag_tfr==1
,
name(years_births, replace)
xtitle("asymptotic global total fertility rate")
ytitle("year in which global birth count falls below level")
graphr(lc(white) c(white))
ylab(,angle(horizontal) nogrid)
ysc(log)
xsize(12) ysize(6)
legend(col(1) pos(3) order(
1 "{bf:200,000}"
- "(≈ 2023 Dominican Republic)"
2 "{bf:2,000,000}"
- "(≈ 2023 Mexico)"
3 "{bf:10,000,000}"
- "(≈ 2023 China)"
4 "{bf:20,000,000}"
- "(≈ 2023 India)"
))
;
#delimit cr

graph save years_births "years_births.gph", replace
graph export "years_births.pdf", as(pdf) replace

gen cumulative = births_cum_1000+120000000000

#delimit ;
twoway 
(connected cumulative year if tfr == 1.8, ms(i) lc(navy) lp(solid)) 
(connected cumulative year if tfr == 1.66, ms(i) lc(forest_green) lp(longdash)) 
(connected cumulative year if tfr == 1.5, ms(i) lc(dkorange) lp(dash)) 
(connected cumulative year if tfr == 1.2, ms(i) lc(maroon) lp(shortdash)) 
if year < 2500
,
name(cumulative, replace)
ysize(6) xsize(12)
graphr(c(white) lc(white))
ylab(120000000000 "120b" 130000000000 "130b" 140000000000 "140b" 150000000000 "150b" ,angle(horizontal) nogrid)
xtitle("")
ytitle("cumulative count of humans ever born")
legend(col(1) pos(2) title("asymptotic TFR:", c(black) size(medium)) order(
1 "{bf:1.80}"
- "(≈ 2023 Mexico)"
2 "{bf:1.66}"
- "(≈ 2023 US)"
3 "{bf:1.50}"
- "(≈ 2023 Europe)"
4 "{bf:1.20}"
- "(≈ 2023 Eastern Asia)"
))
;
#delimit cr
graph save cumulative "cumulative.gph", replace
graph export "cumulative.pdf", as(pdf) replace

**** Dependency

foreach age in total old youth{
local ratio total
if "`age'"=="youth" local ratio youth
if "`age'"=="old" local ratio old age
#delimit ;
twoway
(connected dependency_`age' tfr if year == 2400, ms(i) lw(medthick) lc(navy) lp(solid))
(connected dependency_`age' tfr if year == 2300, ms(i) lw(medthick) lc(forest_green) lp(longdash))
(connected dependency_`age' tfr if year == 2200, ms(i) lw(medthick) lc(dkorange) lp(dash))
(connected dependency_`age' tfr if year == 2150, ms(i) lw(medthick) lc(maroon) lp(shortdash))
(connected dependency_`age' tfr if year == 2025, ms(i) lw(thin) lc(gs4) lp(solid))
if tfr <=2.2
,
graphr(c(white) lc(white))
legend(col(1) pos(3) order(
1 "2400"
2 "2300"
3 "2200"
4 "2150"
5 "2025"
))
xtitle("asymptotic global total fertility rate")
ytitle("`ratio' dependency ratio (per 100)")
ylab(0(50)200,nogrid angle(horizontal))
ysc(r(0 200))
ysize(6) xsize(12)
xsc(r(1 2.25))
xlab(1 "1.00" 1.25 "1.25" 1.5 "1.50" 1.75 "1.75" 2 "2.00" 2.25 "2.25")
name(dependency_`age', replace)
;
#delimit cr
graph save dependency_`age' "dependency_`age'.gph", replace
graph export "dependency_`age'.pdf", as(pdf) replace
}


***** Spike
append using spike_history.dta

#delimit ;
twoway
(connected population year if tfr == 1.80 & year > 2023, ms(i) lw(medthick) lc("214 210 196") lp(dash))
(connected population year if tfr == 1.20 & year > 2023, ms(i) lw(medthick) lc("214 210 196") lp(shortdash))
(connected size_spike year_spike, ms(i) lw(medthick) lc("191 87 0") lp(solid))
(connected population year if tfr == 1.66 & year > 2023, ms(i) lw(medthick) lc("191 87 0") lp(longdash))
,
graphr(c(white) lc(white))
ylab(2000000000 "2b" 4000000000 "4b" 6000000000 "6b" 8000000000 "8b" 10000000000 "10b", nogrid angle(horizontal))
xlab(-10000 " 10,000 BCE" -5000 "5,000 BCE" 0 "1 CE" 5000 "5,000 CE  " )
ytitle("global population size") xtitle("") 
legend(
col(1) stack pos(3) ring(0)  placement(center) symplacement(center) size(small) region(c(none) lc(none)) order(

4 "TFR → 1.66"  - ""
1 "TFR → 1.80"  - ""
2 "TFR → 1.20"  - ""
))
xline(2023, lc("0 95 134") lw(thin))
name(spike_population, replace)
text(10750000000 2023 "2023", placement(north) size(small) c("0 95 134"))
;
#delimit cr
graph save spike_population "spike_population.gph", replace
graph export "spike_population.pdf", as(pdf) replace

append using bspike_history.dta
gen births5 = births/5

#delimit ;
twoway
(connected births5 year if tfr == 1.80 & year > 2023, ms(i) lw(medthick) lc("214 210 196") lp(dash))
(connected births5 year if tfr == 1.20 & year > 2023, ms(i) lw(medthick) lc("214 210 196") lp(shortdash))
(connected births_bspike year_bspike, ms(i) lw(medthick) lc("191 87 0") lp(solid))
(connected births5 year if tfr == 1.66 & year > 2023, ms(i) lw(medthick) lc("191 87 0") lp(longdash))
,
graphr(c(white) lc(white))
ylab( 50000000 "50m" 100000000 "100m" 150000000 "150m", nogrid angle(horizontal))
xlab(-10000 " 10,000 BCE" -5000 "5,000 BCE" 0 "1 CE" 5000 "5,000 CE  " )
ytitle("global count of births per year") xtitle("") 
legend(
col(1) stack pos(3) ring(0)  placement(center) symplacement(center) size(small) region(c(none) lc(none)) order(

4 "TFR → 1.66"  - ""
1 "TFR → 1.80"  - ""
2 "TFR → 1.20"  - ""
))
xline(2023, lc("0 95 134") lw(thin))
name(spike_births, replace)
text(155000000 2023 "2023", placement(north) size(small) c("0 95 134"))
;
#delimit cr
graph save spike_births "spike_births.gph", replace
graph export "spike_births.pdf", as(pdf) replace


*** rebound
clear
import delimited rebound_output.csv, clear

gen birthsX5 = births
replace births = births/5
gen births_tX5 = births_t
replace births_t = births_t/5

sort year
sort tfr_scenario

#delimit ;
twoway 
(connected population_t tfr_scenario if start_converge == 2125, lw(medthick) ms(i) lc(navy) lp(solid)) 
(connected population_t tfr_scenario if start_converge == 2150, lw(medthick) ms(i) lc(forest_green) lp(longdash)) 
(connected population_t tfr_scenario if start_converge == 2175, lw(medthick) ms(i) lc(maroon) lp(dash)) 
(connected births_t tfr_scenario if start_converge == 2125, lw(none) ms(i) lc(navy) lp(solid) yaxis(2)) 
(connected births_t tfr_scenario if start_converge == 2150, lw(none) ms(i) lc(forest_green) lp(longdash) yaxis(2)) 
(connected births_t tfr_scenario if start_converge == 2175, lw(none) ms(i) lc(maroon) lp(dash) yaxis(2)) 
if year == 3000&age == "all"
,
ylab(2000000000 "2b" 4000000000 "4b" 6000000000 "6b" 8000000000 "8b" 10000000000 "10b", nogrid angle(horizontal))
graphr(c(white) lc(white))
xtitle("TFR target towards which world initially converges in 22nd century")
ytitle("asymptotic stationary population size")
ylab(20000000 "20m" 40000000 "40m" 60000000 "60m" 80000000 "80m" 100000000 "100m", nogrid angle(horizontal) axis(2))
ytitle("asymptotic stationary count of births per year", axis(2))
ysize(6) xsize(12)
legend(col(1) pos(3) order(
1 "fertility increase begins in 2125"
2 "fertility increase begins in 2150"
3 "fertility increase begins in 2175"
)
)
name(rebound_size, replace)
xline(1.66, lc(gs8) lw(vthin))
xline(1.5, lc(gs8) lw(vthin))
xline(1.2, lc(gs8) lw(vthin))
text(10500000000 1.67 "US" "in 2023", c(gs8) place(east) size(vsmall) just(left))
text(10500000000 1.51 "Europe" "in 2023", c(gs8) place(east) size(vsmall) just(left))
text(10500000000 1.21 "East Asia" "in 2023", c(gs8) place(east) size(vsmall) just(left)) 
;
#delimit cr

graph save rebound_size "rebound_size.gph", replace
graph export "rebound_size.pdf", as(pdf) replace

keep age tfr_scenario start_converge_t year population_t 

replace age = "1000" if age == "all"
destring age, replace

local list
foreach var in population_t {
rename `var' `var'_
local list `list' `var'_
}
egen j = group(tfr year start)
reshape wide `list', i(j) j(age)
drop j
rename population_t_1000 population_t

local youth
foreach y in 0 5 10{
local youth `youth' population_t_`y'
}

local middle
forvalues y = 15(5)60{
local middle `middle' population_t_`y'
}

local old
forvalues y = 65(5)100{
local old `old' population_t_`y'
}

foreach age in youth middle old{
egen population_`age' = rowtotal(``age'')
}

gen dependency_total = 100*(population_youth + population_old)/population_middle
gen dependency_youth = 100*(population_youth)/population_middle
gen dependency_old = 100*(population_old)/population_middle


#delimit ;
twoway 
(connected dependency_old tfr_scenario if start_converge == 2125, lw(medthick) ms(i) lc(navy) lp(solid)) 
(connected dependency_old tfr_scenario if start_converge == 2150, lw(medthick) ms(i) lc(forest_green) lp(longdash)) 
(connected dependency_old tfr_scenario if start_converge == 2175, lw(medthick) ms(i) lc(maroon) lp(dash)) 
if year == 2200 
,
ylab(, nogrid angle(horizontal))
graphr(c(white) lc(white))
xtitle("TFR target towards which world initially converges in 22nd century")
ytitle("old-age dependency ratio (per 100) in 2200")
ysize(6) xsize(12)
legend(col(1) pos(3) order(
1 "fertility increase begins in 2125"
2 "fertility increase begins in 2150"
3 "fertility increase begins in 2175"
)
)
name(rebound_dependency, replace)
yline(70.05, lc(gs8) lw(vthin))
text(69 1.01 "asymptotic stationary old-age dependency ratio", c(gs8) place(east) size(vsmall) just(left))
;
#delimit cr
graph save rebound_dependency "rebound_dependency.gph", replace
graph export "rebound_dependency.pdf", as(pdf) replace

log close

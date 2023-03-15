clear all
set more off

* insert your own current directory below
cd "/Users/gageweston/Desktop/PWI/Population Projections/spike paper"

cap log close
log using Spike_projections, smcl replace
import delimited main_output.csv, clear


** Abstract facts

sum year if tfr_scenario == "1.5"&population<2e+9&age=="all"
sum year if tfr_scenario == "1.2"&population<2e+9&age=="all"
sum year if tfr_scenario == "1.5"&population<1e+9&age=="all"
sum year if tfr_scenario == "1.2"&population<1e+9&age=="all"

* Use 1000 for whole world age group
replace age = "1000" if age == "all"
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

* global variables for plots
global line_thick medthick
global legend_size medsmall
global xyline_color gs8
global title_size large
global title_margin = 5
global y_size 6
global x_size 12
global x_size_1panel 7
* dashes
global dash_1 dash
global dash_2 longdash
global dash_3 shortdash
* colors
global color_1 blue
global color_2 red
global color_3 green
global color_166 dkorange



global year_end_iso 2800

# delimit ;
twoway

(connected yr_size_10000000 tfr if yr_size_10000000 < $year_end_iso, ms(i) lw($line_thick) lc($color_1) lp($dash_1))
(connected yr_size_100000000 tfr if yr_size_100000000 < $year_end_iso, ms(i) lw($line_thick) lc($color_2) lp($dash_2))
(connected yr_size_1000000000 tfr if yr_size_1000000000 < $year_end_iso, ms(i) lw($line_thick) lc($color_3) lp($dash_3))
if tfr <= 2.05 & tag_tfr == 1
,
name(years_size, replace)
title("(a) Population Size", size($title_size)  margin(b=$title_margin))
xtitle("Long-Run Total Fertility Rate")
ytitle("Year Global Population Size Falls Below Level")
graphr(lc(white) c(white))
ylab(2200 "2200" 2400 "2400" 2600 "2600" 2800 "2800",angle(horizontal) nogrid)
legend(col(1) pos(4) ring(0) region(c(none) lc(none)) order(
1 "{bf:10 M} (≈ 2023 Sweden)"
2 "{bf:100 M} (≈ 2023 Vietnam)"
3 "{bf:1,000 M} (≈ 2023 Sub-Saharan Africa)"
))
xsize(12) ysize(6)
;
#delimit cr



#delimit ;
twoway

(connected yr_births_100000 tfr if yr_births_100000 < $year_end_iso, ms(i) lw($line_thick) lc($color_1) lp($dash_1))
(connected yr_births_1000000 tfr if yr_births_1000000 < $year_end_iso, ms(i) lw($line_thick) lc($color_2) lp($dash_2))
(connected yr_births_10000000 tfr if yr_births_10000000 < $year_end_iso, ms(i) lw($line_thick) lc($color_3) lp($dash_3))
if tfr <= 2.05 & tag_tfr == 1
,
name(years_births, replace)
title("(b) Births per Year", size($title_size) margin(b=$title_margin))
xtitle("Long-Run Total Fertility Rate")
ytitle("Year Global Births per Year Fall Below Level")
graphr(lc(white) c(white))
ylab(2200 "2200" 2400 "2400" 2600 "2600" 2800 "2800",angle(horizontal) nogrid)
xsize(12) ysize(6)
legend(col(1) pos(4) ring(0) region(c(none) lc(none)) order(
1 "{bf:0.1 M} (≈ 2023 Cuba)"
2 "{bf:1 M} (≈ 2023 Iran)"
3 "{bf:10 M} (≈ 2023 China)"
))
;
#delimit cr


graph combine years_size years_births, graphregion(color(white)) name(year_size_births, replace) xcommon ycommon cols(2) xsize(12) ysize(6)
graph display year_size_births
graph export "year_size_births.pdf", as(pdf) replace


**** Dependency

global year_dependency 2400

#delimit ;
twoway
(connected dependency_total tfr if year == $year_dependency, ms(i) lw($line_thick) lc($color_1) lp($dash_1))
(connected dependency_old tfr if year == $year_dependency, ms(i) lw($line_thick) lc($color_2) lp($dash_2))
(connected dependency_youth tfr if year == $year_dependency, ms(i) lw($line_thick) lc($color_3) lp($dash_3))
if tfr != 1.66 & tfr != 1.84 & tfr <= 2
,
graphr(c(white) lc(white))
legend(col(1) pos(2) ring(0) region(c(none) lc(none)) order(
1 "Total (Old + Youth)"
2 "Old (Age 65+)"
3 "Youth (Age < 15)"
))
xtitle("Long-Run Total Fertility Rate")
ytitle("Long-Run Dependency Ratio (Dependents/100 Workers)")
ylab(0(50)200,nogrid angle(horizontal))
ysc(r(0 200))
ysize($y_size) xsize($x_size_1panel)
xsc(r(1 2))
xlab(1 "1" 1.2 "1.2" 1.4 "1.4" 1.6 "1.6" 1.8 "1.8" 2 "2")
yline(53.64622, lc($xyline_color) lw(vthin))
text(58.64622 1.01 "Total in 2025", c($xyline_color) place(east) size(vsmall) just(left))
yline(37.5697, lc($xyline_color) lw(vthin))
text(42.5697 1.01 "Youth in 2025", c($xyline_color) place(east) size(vsmall) just(left))
yline(17.07652, lc($xyline_color) lw(vthin))
text(22.07652 1.01 "Old in 2025", c($xyline_color) place(east) size(vsmall) just(left))
name(dependency, replace)
;
#delimit cr
graph save dependency "dependency.gph", replace
graph export "dependency.pdf", as(pdf) replace


save main.dta, replace



***** Spike
import delimited population_history.csv, clear
sort year
* 2024 data was not in the dataset nor our future projections and needs to be added. insert rounded WPP 2022 version projected population and births for 2024
set obs `=_N+1'
replace year = 2024 if year == .
replace births = 134000000 if year == 2024
replace population = population[_n-1] + 74000000 if year == 2024

* get annual growth rate in annual births
gen timestep = year[_n+1] - year
gen birth_growth_rate = (births[_n+1] / births) ^ (1 / timestep) - 1
gen  pop_growth_rate = (population[_n+1] / population) ^ (1 / timestep) - 1
* duplicate each row by the number of years between that row and the next row
expand timestep, gen(is_duplicate)
* get number of years each duplicate is from the duplicated year to get annual time-steps
bysort year: gen years_since_orig = _n - 1
replace year = year + years_since_orig
* estimate each year's births using that year-group's annual birth growth rate
global history_end 2024
replace births = (births * (1 + birth_growth_rate ) ^ years_since_orig) if year != $history_end
replace population = (population * (1 + pop_growth_rate ) ^ years_since_orig) if year != $history_end

* get cumulative sum of births from start to end of dataset.
* To do this, multiply annual births by the difference in years from 1 period to the next and sum this amount over time
gen cumulative = sum(births)
* add births for the final year since they weren't counted yet
replace cumulative = cumulative + births if year == $history_end
* since total past births was 117B as of 2022, the difference from 117B and the end of our estimates should be added to each year in our estimates
global past_births 117e+9
gen births_dif = $past_births - cumulative
egen births_before_10000_BCE = min(births_dif)
replace cumulative = cumulative + births_before_10000_BCE
drop timestep birth_growth_rate pop_growth_rate is_duplicate years_since_orig births_dif births_before_10000_BCE
* turn annual data into 5-year periods to match rest of data
drop if mod(year,5) != 0

append using main.dta
replace cumulative = births_cum_1000 + $past_births if year > $history_end


global line_2023_color $xyline_color
* 0 95 134
global start_cum -10000
global end_cum 4000
global color_other_TFR = "214 210 196"
global dash_180 = "dash"
global dash_166 = "longdash"
global dash_120 = "shortdash"

#delimit ;
twoway 
(connected cumulative year if tfr == 1.8 & year <= $end_cum & year >= $history_end, ms(i) lc("$color_other_TFR") lp($dash_180))  
(connected cumulative year if tfr == 1.2 & year <= $end_cum & year > 2100, ms(i) lc("$color_other_TFR") lp($dash_120)) 
(connected cumulative year if tfr == 1.66 & year <= $end_cum & year > 2100, ms(i) lc($color_166) lp($dash_166)) 
(connected cumulative year if year <= $history_end + 5 & year >= $start_cum, ms(i) lw($line_thick) lc($color_166) lp(solid))
,
name(cumulative_history, replace)
ysize($y_size) xsize($x_size)
graphr(c(white) lc(white))
ylab(0 "0" 30e+9 "30 B" 60e+9 "60 B" 90e+9 "90 B" 120e+9 "120 B" 150e+9 "150 B",angle(horizontal) nogrid)
title("(a) Very Long-Run", size($title_size)  margin(b=$title_margin))
xtitle("")
ytitle("Cumulative Humans Ever Born")
xlab(-10000 "  10,000 BCE" -5000 "5,000 BCE" 0 "1 CE" 4000 "4,000 CE    " )
legend(off)
xline(2023, lc("$xyline_color") lw(thin))
text(157e+9 2023 "2023", placement(north) size(small) c("$xyline_color"))
;
#delimit cr


global end_cum 2400

#delimit ;
twoway 
(connected cumulative year if tfr == 1.8 & year <= $end_cum & year > $history_end, ms(i) lw($line_thick) lc("$color_other_TFR") lp($dash_180)) 
(connected cumulative year if tfr == 1.2 & year <= $end_cum & year > $history_end, ms(i) lw($line_thick) lc("$color_other_TFR") lp($dash_120)) 
(connected cumulative year if tfr == 1.66 & year <= $end_cum & year > $history_end, ms(i) lw($line_thick) lc($color_166) lp($dash_166))  
,
name(cumulative, replace)
ysize($y_size) xsize($x_size)
graphr(c(white) lc(white))
ylab(120e+9 "120 B" 130e+9 "130 B" 140e+9 "140 B" 150e+9 "150 B" ,angle(horizontal) nogrid)
title("(b) In Detail", size($title_size) margin(b=$title_margin))
xtitle("")
ytitle("Cumulative Humans Ever Born")
xlab(2023 "2023" 2100 "2100" 2200 "2200" 2300 "2300" 2400 "2400")
legend(col(1) pos(4) ring(0) title("Long-Run TFR", c(black) size($legend_size)) region(c(none) lc(none)) order(
1 "{bf:1.80} (≈ 2023 Mexico)"
3 "{bf:1.66} (≈ 2023 US)"
2 "{bf:1.20} (≈ 2023 Eastern Asia)"
))
;
#delimit cr




graph combine cumulative_history cumulative, graphregion(color(white)) name(cum_births, replace) cols(2) xsize(12) ysize(6)
graph display cum_births
graph export "cum_births.pdf", as(pdf) replace



* spike graph - population and annual births

global end_spike 4000
global line_thick_2 medium

#delimit ;
twoway
(connected population year if tfr == 1.80 & year > $history_end & year <= $end_spike, ms(i) lw($line_thick_2) lc("$color_other_TFR") lp($dash_180))
(connected population year if tfr == 1.20 & year > $history_end & year <= $end_spike, ms(i) lw($line_thick_2) lc("$color_other_TFR") lp($dash_120))
(connected population year if tfr == 1.66 & year > $history_end & year <= $end_spike, ms(i) lw($line_thick) lc($color_166) lp($dash_166))
(connected population year if year <= 2023, ms(i) lw(medthick) lc($color_166) lp(solid))
,
graphr(c(white) lc(white))
ylab(0 "0" 2000000000 "2 B" 4000000000 "4 B" 6000000000 "6 B" 8000000000 "8 B" 10000000000 "10 B", nogrid angle(horizontal))
xlab(-10000 " 10,000 BCE" -5000 "5,000 BCE" 0 "1 CE" 4000 "4,000 CE  " )
ytitle("Global Population Size") xtitle("") 
title("(a) Population Size", size($title_size) margin(b=$title_margin))
legend(
col(1) stack pos(3) ring(1)  placement(center) symplacement(center) size(small) region(c(none) lc(none)) order(
1 "TFR → 1.80"  - ""
3 "TFR → 1.66"  - ""
2 "TFR → 1.20"  - ""
))
xline(2023, lc("$xyline_color") lw(thin))
text(10750000000 2023 "2023", placement(north) size(small) c("$xyline_color"))
name(spike_population, replace)
;
#delimit cr


gen births5 = births/5

#delimit ;
twoway
(connected births5 year if tfr == 1.80 & year > $history_end & year <= $end_spike, ms(i) lw($line_thick_2) lc("$color_other_TFR") lp($dash_180))
(connected births5 year if tfr == 1.20 & year > $history_end & year <= $end_spike, ms(i) lw($line_thick_2) lc("$color_other_TFR") lp($dash_120))
(connected births5 year if tfr == 1.66 & year > $history_end & year <= $end_spike, ms(i) lw($line_thick) lc($color_166) lp($dash_166))
(connected births year if year <= 2023, ms(i) lw(medthick) lc($color_166) lp(solid))
,
graphr(c(white) lc(white))
ylab(0 "0" 50000000 "50 M" 100000000 "100 M" 150000000 "150 M", nogrid angle(horizontal))
xlab(-10000 " 10,000 BCE" -5000 "5,000 BCE" 0 "1 CE" 4000 "4,000 CE  " )
title("(b) Births per Year", size($title_size) margin(b=$title_margin))
ytitle("Global Births per Year") xtitle("") 
legend(
col(1) stack pos(3) ring(1)  placement(center) symplacement(center) size(small) region(c(none) lc(none)) order(
1 "TFR → 1.80"  - ""
3 "TFR → 1.66"  - ""
2 "TFR → 1.20"  - ""
))
xline(2023, lc("$line_2023_color") lw(thin))
text(155000000 2023 "2023", placement(north) size(small) c("0 95 134"))
name(spike_births, replace)
;
#delimit cr


* combine spike graphs
graph combine spike_population spike_births, graphregion(color(white)) name(spike, replace) cols(2) xsize(12) ysize(6)
graph display spike
graph export "spike.pdf", as(pdf) replace



*** rebound


* rebound population and births
clear
import delimited rebound_output.csv, clear
replace births_t = births_t/5
sort year tfr_scenario start_converge_t

local start_1 = 2125
local start_2 = 2150
local start_3 = 2175

#delimit ;
twoway 
(connected population_t tfr_scenario if start_converge_t == `start_1', lw($line_thick) ms(i) lc($color_1) lp($dash_1)) 
(connected population_t tfr_scenario if start_converge_t == `start_2', lw($line_thick) ms(i) lc($color_2) lp($dash_2)) 
(connected population_t tfr_scenario if start_converge_t == `start_3', lw($line_thick) ms(i) lc($color_3) lp($dash_3)) 
(connected births_t tfr_scenario if start_converge_t == `start_1', lw(none) ms(i) lc($color_1) lp($dash_1) yaxis(2)) 
(connected births_t tfr_scenario if start_converge_t == `start_2', lw(none) ms(i) lc($color_2) lp($dash_2) yaxis(2)) 
(connected births_t tfr_scenario if start_converge_t == `start_3', lw(none) ms(i) lc($color_3) lp($dash_3) yaxis(2)) 
if year == 2500 & tfr_scenario <= 2 & tfr_scenario != 1.66
,
ylab(0 "0" 2e+9 "2 B" 4e+9 "4 B" 6e+9 "6 B" 8e+9 "8 B" 10e+9 "10 B", nogrid angle(horizontal))
graphr(c(white) lc(white))
xtitle("Long-Run Total Fertility Rate before Rebound")
ytitle("Global Population Size After Stabilization")
ylab(0 "0" 20000000 "20 M" 40000000 "40 M" 60000000 "60 M" 80000000 "80 M" 100000000 "100 M", nogrid angle(horizontal) axis(2))
title("(a) Population and Births by TFR", size($title_size) margin(b=$title_margin))
ytitle("Births Per Year After Stabilization", axis(2))
ysize($y_size) xsize($x_size)
legend(off)
name(rebound_size, replace)
;
#delimit cr



* rebound timing

tostring tfr_scenario, gen(tfr_scenario_2) force
destring tfr_scenario_2, replace
replace tfr_scenario_2 =round(tfr_scenario_2, 0.01)
tostring tfr_scenario_2, gen(tfr_scenario_3) force
drop tfr_scenario tfr_scenario_2
rename tfr_scenario_3 tfr_scenario


#delimit ;
twoway 
(connected population_t year if start_converge_t == `start_1', lw($line_thick) ms(i) lc($color_1) lp($dash_1)) 
(connected population_t year if start_converge_t == `start_2', lw($line_thick) ms(i) lc($color_2) lp($dash_2)) 
(connected population_t year if start_converge_t == `start_3', lw($line_thick) ms(i) lc($color_3) lp($dash_3)) 
if year <= 2400 & tfr_scenario == "1.66"
,
ylab(0 "0" 2e+9 "2 B" 4e+9 "4 B" 6e+9 "6 B" 8e+9 "8 B" 10e+9 "10 B", nogrid angle(horizontal))
xlab(2023 "2023" 2100 "2100" 2200 "2200" 2300 "2300" 2400 "2400")
graphr(c(white) lc(white))
title("(b) Population by Year (TFR → 1.66)", size($title_size) margin(b=$title_margin))
xtitle("Year")
ytitle("Global Population Size")
legend(col(1) pos(5) ring(0) title("Fertility Rebounds" "to Replacement at:", c(black) size($legend_size)) region(c(none) lc(none)) order(
1 "`start_1'"
2 "`start_2'"
3 "`start_3'"
)
)
ysize($y_size) xsize($x_size)
name(rebound_timing, replace)
;
#delimit cr



* combine rebound
graph combine rebound_size rebound_timing, graphregion(color(white)) name(rebound, replace) cols(2) xsize(12) ysize(6) ycommon
graph display rebound
graph export "rebound.pdf", as(pdf) replace






* annual and generational rates of depopulation
* this will go in the appendix
import delimited main_output.csv, clear

global year_old 3000
global year_new = 4000

replace tfr_scenario = "2.05" if tfr_scenario == "replacement"
destring tfr_scenario, replace
keep if tfr_scenario < 2.1 & age == "all" & year == $year_old
keep tfr_scenario population
rename population pop_old
save past_pop.dta

import delimited main_output.csv, clear
replace tfr_scenario = "2.05" if tfr_scenario == "replacement"
destring tfr_scenario, replace
keep if tfr_scenario < 2.1 & age == "all" & year == $year_new
keep tfr_scenario population
merge m:m tfr_scenario using past_pop.dta
drop _merge
erase past_pop.dta
drop if tfr_scenario == 1.66 | tfr_scenario == 1.84
gen pop_growth_per_year = 100 * (1 - (population / pop_old ) ^ (1 / ($year_new - $year_old)))
gen pop_growth_per_generation = 100 * ( 1 - tfr_scenario / 2.045)
drop population pop_old


#delimit ;
twoway 
(line pop_growth_per_year tfr_scenario, lw(none) lc($color_1) lp(solid)) 
(line pop_growth_per_generation tfr_scenario, yaxis(2) lw($line_thick) lc($color_2) lp(solid))
,
ylab(0 "0%" 0.5 "-0.5%" 1 "-1%" 1.5 "-1.5%" 2 "-2%", nogrid angle(horizontal) axis(1))
ylab(0 "0%" 10 "-10%" 20 "-20%" 30 "-30%" 40 "-40%" 50 "-50%", nogrid angle(horizontal) axis(2))
graphr(c(white) lc(white))
xtitle("Long-Run Total Fertility Rate")
ytitle("Population Growth per Year", axis(1))
ytitle("Population Growth per Generation", axis(2))
ysize($y_size) xsize($x_size_1panel)
legend(off)
name(growth_rates, replace)
;
#delimit cr
graph save growth_rates "growth_rates.gph", replace
graph export "growth_rates.pdf", as(pdf) replace


*** finish

erase main.dta

log close


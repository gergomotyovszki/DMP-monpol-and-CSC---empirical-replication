
clear all
set more off

program main

local ssc_packages "sencode sdecode"
* *** Add required packages from SSC to this list ***

if !missing("`ssc_packages'") {
	foreach pkg of local ssc_packages {
		dis "Installing `pkg'"
		quietly ssc install `pkg', replace
	}
}

    * Install packages using net
    quietly net from "https://raw.githubusercontent.com/gslab-econ/stata-misc/master/"
    quietly cap ado uninstall yaml
    quietly net install yaml
    quietly net from "https://raw.githubusercontent.com/gslab-econ/gslab_stata/master/gslab_misc/ado"
    quietly cap net uninstall matrix_to_txt
    quietly net install matrix_to_txt
    quietly cap net uninstall preliminaries
    quietly net install preliminaries
end

main




#!/bin/bash
faust -lang jsfx gmem_spat_auto.dsp -o build/folia_gmem_spat_auto.jsfx
faust -lang jsfx harm.dsp -o build/folia_harm.jsfx
faust -lang jsfx delay.dsp -o build/folia_delay.jsfx
faust -lang jsfx vital_rev.dsp -o build/folia_vital_rev.jsfx
faust -lang jsfx vital_rev_inf.dsp -o build/folia_vital_rev_inf.jsfx

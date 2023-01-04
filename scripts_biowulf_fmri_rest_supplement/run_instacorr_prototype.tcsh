#!/bin/tcsh

# An early version of driving InstaCorr functionality in the AFNI GUI,
# for errts (residual) time series.
#
# NB: this has since been superceded by the run_instacorr*.tcsh
# scripts that are automatically created by afni_proc.py and put into
# each results directory.  We leave this simple-ish file in purely as
# an example from which users might want to make their own scripts.

set dset_ulay   = anat_final.FT+tlrc.HEAD

set ic_dset     = errts.FT+tlrc.HEAD
set ic_seedrad  = 4.0
set ic_ignore   = 0
set ic_blur     = 0
set ic_automask = no
set ic_despike  = no
set ic_polort   = -1                     # bc errts should have zero baseline
set ic_method   = P

set olay_alpha  = "Quadratic"
set olay_boxed  = "No"
set thresh      = 0.4
set coord       = ( -33 6 46 )

# ===========================================================================

afni -q -no1D -noplugins -no_detach  -echo_edu                          \
     -com "SWITCH_UNDERLAY    ${dset_ulay}"                             \
     -com "INSTACORR INIT                                               \
                     DSET=${ic_dset}                                    \
                   IGNORE=${ic_ignore}                                  \
                     BLUR=${ic_blur}                                    \
                 AUTOMASK=${ic_automask}                                \
                  DESPIKE=${ic_despike}                                 \
                   POLORT=${ic_polort}                                  \
                  SEEDRAD=${ic_seedrad}                                 \
                   METHOD=${ic_method}"                                 \
     -com "INSTACORR SET      ${coord} J"                               \
     -com "SET_THRESHNEW      ${thresh}"                                \
     -com "SET_FUNC_ALPHA     ${olay_alpha}"                            \
     -com "SET_FUNC_BOXED     ${olay_boxed}"                            \
     &


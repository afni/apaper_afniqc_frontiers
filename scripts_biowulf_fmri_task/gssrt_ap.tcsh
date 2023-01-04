#!/bin/tcsh

echo "++ Run GSSRT on AP_21 runs"
echo "-----------------------------------------------------"

# for task, and no ses level here

cd ..
set here = $PWD


# list of all subj
cd data_00_basic 
set all_subj_grp = ( sub-* )
cd -

set Nall = ${#all_subj_grp}

echo "==========================================================="
echo "++ All AP, Nsubj = ${Nall}"
echo "-------------------------------"

# list of subj who completed
cd data_21_ap_task_NL
mkdir -p GSSRT

set all_infiles = ( sub*/s*.results/out.ss*.txt )

# here, diff than rest
echo "---- EXCLUDE ----"
gen_ss_review_table.py                                          \
    -outlier_sep space                                          \
    -report_outliers 'final DF fraction'         LE 0.6         \
    -report_outliers 'censor fraction'           GE 0.2         \
    -report_outliers 'fraction TRs censored'     GE 0.2         \
    -report_outliers 'average censored motion'   GE 0.15        \
    -report_outliers 'max censored displacement' GE 8           \
    -report_outliers 'global correlation (GCOR)' GE 0.20        \
    -report_outliers 'flip guess'                EQ DO_FLIP     \
    -infiles         ${all_infiles}                             \
    |& tee GSSRT/table_gssrt_ALL_exclude.dat

echo "---- WARNS ----"
gen_ss_review_table.py                                          \
    -outlier_sep space                                          \
    -report_outliers 'final DF fraction'         LE 0.7         \
    -report_outliers 'censor fraction'           GE 0.15        \
    -report_outliers 'fraction TRs censored'     GE 0.15        \
    -report_outliers 'average censored motion'   GE 0.1         \
    -report_outliers 'max censored displacement' GE 6           \
    -report_outliers 'global correlation (GCOR)' GE 0.15        \
    -report_outliers 'TSNR average'              LT 150         \
    -infiles         ${all_infiles}                             \
    |& tee GSSRT/table_gssrt_ALL_warns.dat

echo "---- CONSISTENCY ----"
gen_ss_review_table.py                                          \
      -outlier_sep space                                        \
      -report_outliers 'AFNI version'           VARY            \
      -report_outliers 'num regs of interest'   VARY            \
      -report_outliers 'final voxel resolution' VARY            \
      -report_outliers 'num TRs per run'        VARY            \
      -infiles         ${all_infiles}                           \
      |& tee GSSRT/table_gssrt_ALL_consistency.dat

cd -

echo "====================================================================="

set otgz = qc_gssrt_ap_all.tgz
echo "++ ... And pack up all GSSRT files:  ${otgz}"
tar -zcf ${otgz} data_21_ap_task_NL/GSSRT/*dat

echo ""
echo "++ Done"

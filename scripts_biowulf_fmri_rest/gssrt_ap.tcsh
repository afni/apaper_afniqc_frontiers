#!/bin/tcsh

echo "++ Run GSSRT on each Group's AP runs"
echo "-----------------------------------------------------"

cd ..
set here = $PWD

foreach gg ( `seq 1 1 7` )

    # list of all subj
    cd data_00_basic 
    set all_subj_grp = ( sub-${gg}* )
    cd -

    set Nall = ${#all_subj_grp}

    echo "==========================================================="

    echo "++ Group ${gg}, Nsubj = ${Nall}"
    echo "-------------------------------"

    # list of subj who completed
    cd data_2${gg}_ap_rest_NL
    mkdir -p GSSRT

    set all_infiles = ( sub*/ses*/s*.results/out.ss*.txt )

    echo "----- EXCLUDE ------"
    gen_ss_review_table.py                                          \
        -outlier_sep space                                          \
        -report_outliers 'final DF fraction'         LE 0.6         \
        -report_outliers 'censor fraction'           GE 0.2         \
        -report_outliers 'average censored motion'   GE 0.15        \
        -report_outliers 'max censored displacement' GE 8           \
        -report_outliers 'global correlation (GCOR)' GE 0.20        \
        -report_outliers 'flip guess'                EQ DO_FLIP     \
        -infiles         ${all_infiles}                             \
        |& tee GSSRT/table_gssrt_Group_${gg}_exclude.dat

    echo "----- WARNS ------"
    gen_ss_review_table.py                                          \
        -outlier_sep          space                                 \
        -report_outliers      'final DF fraction'         LE 0.7    \
        -report_outliers      'censor fraction'           GE 0.15   \
        -report_outliers      'average censored motion'   GE 0.1    \
        -report_outliers      'max censored displacement' GE 6      \
        -report_outliers      'global correlation (GCOR)' GE 0.15   \
        -report_outliers      'TSNR average'              LT 150    \
        -infiles              ${all_infiles}                        \
        |& tee GSSRT/table_gssrt_Group_${gg}_warns.dat

    echo "----- CONSISTENCY ------"
    gen_ss_review_table.py                                          \
          -outlier_sep space                                        \
          -report_outliers 'AFNI version'           VARY            \
          -report_outliers 'num regs of interest'   VARY            \
          -report_outliers 'final voxel resolution' VARY            \
          -report_outliers 'num TRs per run'        VARY            \
          -infiles         ${all_infiles}                           \
          |& tee GSSRT/table_gssrt_Group_${gg}_consistency.dat

    cd -

end

echo "====================================================================="

set otgz = qc_gssrt_ap_all.tgz
echo "++ ... And pack up all GSSRT files:  ${otgz}"
tar -zcf ${otgz} data_2[1-7]*_ap*/GSSRT/*dat

echo ""
echo "++ Done"

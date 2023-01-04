#!/bin/tcsh

echo "++ Check for successful completion of AP_21 runs"
echo "-----------------------------------------------------"
cd ..

set here = $PWD

# list of all subj
cd data_00_basic 
\ls -d sub-* > ${here}/__tmp1_all.txt
cd -

set Nall = `cat __tmp1_all.txt | wc -l`

# list of subj who completed
cd data_21_ap_task_NL
find ./ -name "QC_*" | cut -b3-9 | sort > ${here}/__tmp2_comp.txt
cd -

comm -23                \
    __tmp1_all.txt      \
    __tmp2_comp.txt     \
    > __tmp3_diff.txt

set content = `cat __tmp3_diff.txt | wc -l`

if ( "${content}" != 0 ) then
    echo "+* INCOMPLETE (in N = ${Nall})"
    cat __tmp3_diff.txt
else
    echo "++ No missing (in N = ${Nall})"
endif

\rm __tmp*.txt

cd -
echo "-----------------------------------------------------"
echo "++ Done"

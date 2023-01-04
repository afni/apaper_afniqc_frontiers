#!/bin/tcsh

echo "++ Check for successful completion of AP proc runs"
echo "-----------------------------------------------------"
cd ..

set here = $PWD

foreach gg ( `seq 1 1 7` )

    # list of all subj
    cd data_00_basic 
    \ls -d sub-${gg}* > ${here}/__tmp1_all_${gg}.txt
    cd -

    set Nall = `cat __tmp1_all_${gg}.txt | wc -l`

    # list of subj who completed
    cd data_2${gg}_ap_rest_NL
    find ./ -name "QC_*" | cut -b3-9 | sort > ${here}/__tmp2_comp_${gg}.txt
    cd -

    comm -23                      \
        __tmp1_all_${gg}.txt      \
        __tmp2_comp_${gg}.txt     \
        > __tmp3_diff_${gg}.txt

    set content = `cat __tmp3_diff_${gg}.txt | wc -l`

    if ( "${content}" != 0 ) then
        echo "+* Group ${gg} : INCOMPLETE (in N = ${Nall})"
        cat __tmp3_diff_${gg}.txt
    else
        echo "++ Group ${gg} : No missing (in N = ${Nall})"
    endif

end

\rm __tmp*.txt

cd -
echo "-----------------------------------------------------"
echo "++ Done"

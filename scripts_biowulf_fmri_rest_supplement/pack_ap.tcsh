#!/bin/tcsh

echo "++ Pack up APQC HTML dirs per group"

cd ..

foreach gg ( `seq 1 1 7` )
    set topdir = data_2${gg}_ap_rest_NL
    set otgz   = qc_${topdir}.tgz
    echo "++ Pack up Group ${gg}:  ${otgz}"
    tar -zcf ${otgz} ${topdir}/sub-*/ses*/*results/QC_*
end

cd -

echo "++ Done"

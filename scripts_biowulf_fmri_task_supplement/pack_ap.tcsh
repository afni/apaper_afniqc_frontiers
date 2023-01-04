#!/bin/tcsh

echo "++ Pack up APQC HTML dirs per group"

cd ..

set topdir = data_21_ap_task_NL
set otgz   = qc_${topdir}.tgz
echo "++ Pack up Group:  ${otgz}"
tar -zcf ${otgz} ${topdir}/sub-*/*results/QC_*

cd -

echo "++ Done"

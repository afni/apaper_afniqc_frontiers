#!/bin/tcsh

echo "++ Pack up APQC HTML dirs per group"

cd ..

set topdir = data_20_ap_simple
set otgz   = qc_${topdir}.tgz
echo "++ Pack up Group 'simple':  ${otgz}"
tar -zcf ${otgz} ${topdir}/sub-*/ses*/*results/QC_*


cd -

echo "++ Done"

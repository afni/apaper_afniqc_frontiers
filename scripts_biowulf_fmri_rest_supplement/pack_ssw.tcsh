#!/bin/tcsh

echo "++ Pack up SSW images"

cd ..

set topdir = data_13_ssw
set otgz   = qc_${topdir}.tgz
echo "++ Pack up all:  ${otgz}"
tar -zcf ${otgz} ${topdir}/sub-*/ses*/*jpg

cd -

echo "++ Done"

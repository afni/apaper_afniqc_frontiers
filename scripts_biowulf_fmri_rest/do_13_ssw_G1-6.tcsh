#!/bin/tcsh

# SSW: run @SSwarper to skullstrip (SS) and estimate a nonlinear warp.
# -> this version uses mask_ss from FS

# NOTES
#
# + This is a Biowulf script (has slurm stuff)
# + Run this script in the scripts/ dir, via the corresponding run_*tcsh

# ----------------------------- biowulf-cmd ---------------------------------
# load modules
source /etc/profile.d/modules.csh
module load afni

# set N_threads for OpenMP
# + consider using up to 4 threads, because of "-parallel" in recon-all
setenv OMP_NUM_THREADS $SLURM_CPUS_PER_TASK

# compress BRIK files
setenv AFNI_COMPRESSOR GZIP

# initial exit code; we don't exit at fail, to copy partial results back
set ecode = 0
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
set ses            = $2

set template       = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_deob       = ${dir_inroot}/data_05_deob
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw

# subject directories
set sdir_basic     = ${dir_basic}/${subj}/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_anat      = ${sdir_basic}/anat
set sdir_deob      = ${dir_deob}/${subj}/${ses}
set sdir_deob_anat = ${sdir_deob}/anat
set sdir_fs        = ${dir_fs}/${subj}/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set dset_anat_05  = ${sdir_deob_anat}/${subj}*T1w.nii.gz

# control variables

# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -disp_num_cpu`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ----------------------------- biowulf-cmd --------------------------------
# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_ssw}
    set sdir_ssw  = /lscratch/$SLURM_JOBID/${subj}_${ses}

    # prep for group permission reset
    \mkdir -p ${sdir_BW}
    set grp_own = `\ls -ld ${sdir_BW} | awk '{print $4}'`
else
    set usetemp  = 0
endif
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

\mkdir -p "${sdir_ssw}"

# regrid WB mask from @SUMA_Make_Spec_FS to input anat grid

set dset_mask_ss = ${sdir_ssw}/mask_${subj}.nii.gz

3dAllineate                                                                  \
    -1Dmatrix_apply  IDENTITY                                                \
    -final           NN                                                      \
    -source          ${sdir_suma}/fs_parc_wb_mask.nii*                       \
    -master          "${dset_anat_05}"                                       \
    -prefix          "${dset_mask_ss}"

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

time @SSwarper                                                               \
    -base           "${template}"                                            \
    -subid          "${subj}"                                                \
    -mask_ss        "${dset_mask_ss}"                                        \
    -input          "${dset_anat_05}"                                        \
    -cost_nl_final  lpa                                                      \
    -odir           "${sdir_ssw}"

if ( ${status} ) then
    set ecode = 2
    goto COPY_AND_EXIT
endif

echo "++ done proc ok"

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------
# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_ssw} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_ssw}"
    echo "          to: ${sdir_BW}"
    \mkdir -p ${sdir_BW}
    \cp -pr   ${sdir_ssw}/* ${sdir_BW}/.

    # reset group permission
    chgrp -R ${grp_own} ${sdir_BW}
    chmod -R g+w ${sdir_BW}
endif
# ---------------------------------------------------------------------------

if ( ${ecode} ) then
    echo "++ BAD FINISH: SSW (ecode = ${ecode})"
else
    echo "++ GOOD FINISH: SSW"
endif

exit ${ecode}


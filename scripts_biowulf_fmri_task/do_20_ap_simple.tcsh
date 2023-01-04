#!/bin/tcsh

# AP_SIMPLE: quick/simple AP, treat everything like rest, mainly for QC

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
#set ses            = $2
set ap_label       = 20_ap_simple

set template       = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_deob       = ${dir_inroot}/data_05_deob
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_ap         = ${dir_inroot}/data_${ap_label}

# subject directories
set sdir_basic     = ${dir_basic}/${subj} #/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_anat      = ${sdir_basic}/anat
set sdir_deob      = ${dir_deob}/${subj} #/${ses}
set sdir_deob_anat = ${sdir_deob}/anat
set sdir_fs        = ${dir_fs}/${subj} #/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj} #/${ses}
set sdir_ap        = ${dir_ap}/${subj} #/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set dsets_epi     = ( ${sdir_epi}/${subj}_*task*bold.nii* )

set dset_anat_05  = ${sdir_deob_anat}/${subj}*T1w.nii.gz
set anat_cp       = ${sdir_ssw}/anatSS.${subj}.nii
set anat_skull    = ${sdir_ssw}/anatU.${subj}.nii

set dsets_NL_warp = ( ${sdir_ssw}/anatQQ.${subj}.nii         \
                      ${sdir_ssw}/anatQQ.${subj}.aff12.1D    \
                      ${sdir_ssw}/anatQQ.${subj}_WARP.nii  )

# might not always use these
set roi_all_2009  = ${sdir_suma}/aparc.a2009s+aseg_REN_all.nii.gz
set roi_FSvent    = ${sdir_suma}/fs_ap_latvent.nii.gz
set roi_FSWe      = ${sdir_suma}/fs_ap_wm.nii.gz

# control variables
set nt_rm         = 3


# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -disp_num_cpu`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ----------------------------- biowulf-cmd --------------------------------
# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_ap}
    set sdir_ap  = /lscratch/$SLURM_JOBID/${subj} #_${ses}

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

set ap_cmd = ${sdir_ap}/ap.cmd.${subj}

\mkdir -p ${sdir_ap}

# write AP command to file
cat <<EOF >! ${ap_cmd}

ap_run_simple_rest.tcsh                                               \
    -run_ap                                                           \
    -subjid   ${subj}                                                 \
    -nt_rm    ${nt_rm}                                                \
    -anat     ${dset_anat_05}                                         \
    -epi      ${dsets_epi}

EOF

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

cd ${sdir_ap}

# execute AP command to make processing script
tcsh -xef ${ap_cmd} |& tee output.ap.cmd.${subj}

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

# execute the proc script, saving text info
time tcsh -xef proc.${subj} |& tee output.proc.${subj}

if ( ${status} ) then
    echo "++ FAILED AP: ${ap_label}"
    set ecode = 1
    goto COPY_AND_EXIT
else
    echo "++ FINISHED AP: ${ap_label}"
endif

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------
# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_ap} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_ap}"
    echo "          to: ${sdir_BW}"
    \mkdir -p ${sdir_BW}
    \cp -pr   ${sdir_ap}/* ${sdir_BW}/.

    # reset group permission
    chgrp -R ${grp_own} ${sdir_BW}
    chmod -R g+w ${sdir_BW}
endif
# ---------------------------------------------------------------------------

if ( ${ecode} ) then
    echo "++ BAD FINISH: AP (ecode = ${ecode})"
else
    echo "++ GOOD FINISH: AP"
endif

exit ${ecode}


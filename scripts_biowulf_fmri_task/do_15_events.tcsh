#!/bin/tcsh

# EVENTS: create stim events files, here from "simple" TSV in timing file
# NO session level here

# NOTES
#
# + This is a Biowulf script (has slurm stuff)
# + Run this script in the scripts/ dir, via the corresponding run_*tcsh
# + NO session level here.

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

set template       = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_deob       = ${dir_inroot}/data_05_deob
set dir_timing     = ${dir_inroot}/data_01_timing    # simple timing available
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_events     = ${dir_inroot}/data_15_events

# subject directories
set sdir_basic     = ${dir_basic}/${subj} #/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_anat      = ${sdir_basic}/anat
set sdir_deob      = ${dir_deob}/${subj} #/${ses}
set sdir_deob_anat = ${sdir_deob}/anat
set sdir_timing    = ${dir_timing}/${subj}/func #/${ses}
set sdir_fs        = ${dir_fs}/${subj} #/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj} #/${ses}
set sdir_events    = ${dir_events}/${subj} #/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set dset_anat_05  = ${sdir_deob_anat}/${subj}*T1w.nii.gz

# original/complicated timing file (actually used here)
set timing_in     = ( ${sdir_epi}/${subj}*pamenc*events.tsv )
# ... and just to note, the simplified timing file version (could be used)
###set timing_simple = ( ${sdir_timing}/simple*${subj}*pamenc*events.tsv )

# control variables

# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -disp_num_cpu`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ----------------------------- biowulf-cmd --------------------------------
# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_events}
    set sdir_events  = /lscratch/$SLURM_JOBID/${subj} #_${ses}

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

\mkdir -p ${sdir_events}

# select columns within timing file ('duration' is for default timing case)
timing_tool.py                                                               \
    -multi_timing_3col_tsv  ${timing_in}                                     \
    -tsv_labels             onset reaction_time trial_type                   \
    -tsv_def_dur_label      duration                                         \
    -write_multi_timing     ${sdir_events}/

# and make an event_list file, for easy perusal
timing_tool.py                                                               \
    -multi_timing                ${sdir_events}/times.*.txt                  \
    -multi_timing_to_event_list  GE:ALL ${sdir_events}/events.txt

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

echo "++ done proc ok"

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------
# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_events} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_events}"
    echo "          to: ${sdir_BW}"
    \mkdir -p ${sdir_BW}
    \cp -pr   ${sdir_events}/* ${sdir_BW}/.

    # reset group permission
    chgrp -R ${grp_own} ${sdir_BW}
    chmod -R g+w ${sdir_BW}
endif
# ---------------------------------------------------------------------------

if ( ${ecode} ) then
    echo "++ BAD FINISH: EVENTS (ecode = ${ecode})"
else
    echo "++ GOOD FINISH: EVENTS"
endif

exit ${ecode}


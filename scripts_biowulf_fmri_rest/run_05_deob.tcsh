#!/bin/tcsh

# DEOB: deoblique the anatomical, preserving the coord origin
# -> prior to running FS

# NOTES
#
# + This is a Biowulf script (has slurm stuff)
# + Run this script in the scripts/ dir, to execute the corresponding do_*tcsh

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 05_deob

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs
set dir_swarm     = ${dir_inroot}/swarms
set dir_basic     = ${dir_inroot}/data_00_basic


# running
set cdir_log      = ${dir_log}/logs_${cmd}
set scr_swarm     = ${dir_swarm}/swarm_${cmd}.txt
set scr_cmd       = ${dir_scr}/do_${cmd}.tcsh

# --------------------------------------------------------------------------

\mkdir -p ${cdir_log}
\mkdir -p ${dir_swarm}

# clear away older swarm script 
if ( -e ${scr_swarm} ) then
    \rm ${scr_swarm}
endif

# --------------------------------------------------------------------------

# get list of all subj IDs for proc
cd ${dir_basic}
set all_subj = ( sub-* )
cd -

cat <<EOF

++ Proc command:  ${cmd}
++ Found ${#all_subj} subj:

EOF

# -------------------------------------------------------------------------
# build swarm command

# loop over all subj
foreach subj ( ${all_subj} )
    echo "++ Prepare cmd for: ${subj}"

    # loop over all ses
    cd ${dir_basic}/${subj}
    set all_ses = ( ses-* )
    cd -

    foreach ses ( ${all_ses} )
        set log = ${cdir_log}/log_${cmd}_${subj}_${ses}.txt

        # run command script (verbosely, and don't use '-e'); log terminal text.
        echo "tcsh -xf ${scr_cmd} ${subj} ${ses} \\"    >> ${scr_swarm}
        echo "     |& tee ${log}"                       >> ${scr_swarm}
    end
end

# -------------------------------------------------------------------------
# run swarm command
cd ${dir_scr}

echo "++ And start swarming: ${scr_swarm}"

# don't need to use lscratch for this
swarm                                                              \
    -f ${scr_swarm}                                                \
    --partition=norm,quick                                         \
    --threads-per-process=1                                        \
    --gb-per-process=2                                            \
    --time=00:03:00                                                \
    #--gres=lscratch:10                                             \
    --logdir=${cdir_log}                                           \
    --job-name=job_${cmd}                                          \
    --merge-output                                                 \
    --usecsh

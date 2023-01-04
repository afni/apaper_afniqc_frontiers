These are supplementary scripts that were useful for some aspects of
checking, packaging and verifying some of the outputs of processing
from resting state FMRI processing.

Some aspects might be specific to processing on Biowulf or with the
specific processing setup here, but they might also be useful for
researchers to make their own, similar scripts.

+ finish_check_*.tcsh

  Check and see if the jobs for a particular step appeared to complete
  successfully for all subjects.

+ pack_*.tcsh

  Make tarballs of useful subsets of the processing for a particular step:
  - for AP, the QC HTML directories.
  - for SSW, the QC JPGs.

+ run_instacorr_prototype.tcsh

  An early example of driving AFNI to setup InstaCorr.  More specific
  versions are output by the AP processing itself now, but this might
  be useful for readers who want to make their own InstaCorr driving
  scripts.

These are supplementary scripts that were useful for some aspects of
checking, packaging and verifying some of the outputs of processing
from task-based FMRI processing.

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


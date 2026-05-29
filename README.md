### Protein Structural Space Analysis Workflow

# step0: use mmseq2 to cluster similar sequence and get represent sequence `seqclust`. (based on Sequence)
# step1: use esmfold to predicted `linclust` sequence, map other sequence to `seqclust`. 
# step2: use foldseek to cluster all the pdb files of `seqclust`, get the `proclust`. (based on pridected Protein strucure)
# step3: use foldseek to alignment all agasin all of `seqclust`, then transfer into matrix. 
# step4: UMAP clustering.

## Please contact me if you have any question


Note: This pipeline is highly optimized for our local HPC cluster environment (using Apptainer for ESMFold and Specific Slurm modules). Paths and module names need to be adapted if running on other environments.

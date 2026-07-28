#!/bin/bash

#SBATCH --job-name=esmfold
#SBATCH --auks=yes
#SBATCH --partition=gpu
#SBATCH --gres=gpu:ampere:1
#SBATCH --ntasks=1
#SBATCH --mem=80G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --output=esm_job_04_%j.out
#SBATCH --error=esm_job_04_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-user=tan@ipk-gatersleben.de

# === Configuration ===
BASE_DIR="${BASE_DIR:-/filer-5/agruppen/PBP/tan}"

# 1. env
module load esm-fold
module load cuda
# For GPU
export APPTAINER_NV=true

# Binding the system/file path
export APPTAINER_BIND="/filer-5:/filer-5"

# 2. file path
INPUT_FASTA="/filer-5/user/tan/evolution/crp/new/alphafold_barley/panbarley.more.pep.fasta"
OUTPUT_DIR="/filer-5/user/tan/evolution/crp/new/alphafold_barley/panbarley_esmfold_more_res"
export TORCH_HOME="$BASE_DIR/software/esmfold"
mkdir -p ${OUTPUT_DIR}

# 3. Running
# -i fasta, -o output_dir
date
echo "Starting ESM-Fold prediction"

${ESMFOLD_CONTAINER} \
  -i ${INPUT_FASTA} \
  -o ${OUTPUT_DIR}

echo "Prediction finished."
date

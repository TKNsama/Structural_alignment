#!/bin/bash
#SBATCH --job-name=fs_crp_clu
#SBATCH --auks=yes                                      # use Kerberos
#SBATCH --partition=cpu                                 # possible values: cpu, gpu
#SBATCH --ntasks=1                                      # Number of tasks (default=1)
#SBATCH --cpus-per-task=16                               # number of cpus for this task (default=1)
#SBATCH --mem=32G                                       # size of memory (default 10G in cpu and gpu)
#SBATCH --nodes=1                                       # Ensure that all cores are on one machine
#SBATCH --output=job_%j.out                             # File to which standard out will be written
#SBATCH --error=job_%j.err                              # File to which standard err will be written
#SBATCH --mail-type=END                                 # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=tan@ipk-gatersleben.de  # Email to which notifications will be sent

# === Configuration ===
BASE_DIR="${BASE_DIR:-/filer-5/agruppen/PBP/tan}"

module load foldseek

# Path
INPUT_PDB_DIR="/filer-5/user/tan/evolution/crp/new/alphafold_barley/odb_all_esmfold_res_filtered/"
RESULT_DIR="/filer-5/user/tan/evolution/crp/new/alphafold_barley/foldseek_results_filtered"
OUTPUT_PREFIX="${RESULT_DIR}/crp_cluster_filtered"
TMP_DIR="${RESULT_DIR}/tmp"

mkdir -p ${RESULT_DIR}
mkdir -p ${TMP_DIR}

# Path checking
if [ ! -d "$INPUT_PDB_DIR" ]; then
    echo "Error: Input directory $INPUT_PDB_DIR does not exist."
    exit 1
fi

date
echo "Starting Foldseek clustering for 8000 proteins..."

# Running
foldseek easy-cluster \
    "${INPUT_PDB_DIR}" \
    "${OUTPUT_PREFIX}" \
    "${TMP_DIR}" \
    --threads 16 \
    -s 9.5 \
    --min-seq-id 0.0 \
    --alignment-type 1 \
    --tmscore-threshold 0.5 \
    --cluster-mode 1 \
    -c 0.3 \
    --cov-mode 1

echo "Clustering finished."
date



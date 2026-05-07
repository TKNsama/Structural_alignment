#!/bin/bash

#SBATCH --job-name=foldseek_linclust
#SBATCH --auks=yes
#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=400G
#SBATCH --nodes=1
#SBATCH --output=logs/foldseek_%j.out
#SBATCH --error=logs/foldseek_%j.err
#SBATCH --mail-type=END
#SBATCH --mail-user=tan@ipk-gatersleben.de

set -e          # 遇到错误立即退出
set -u          # 遇到未定义变量报错
set -o pipefail # 管道错误传递

module load python

MMSEQS="/filer-5/agruppen/PBP/tan/software/mmseqs/bin/mmseqs"

INPUT_FASTA="/home/tan/project/evolution_of_CRP_new/1.putative_CRP/odb_plant_HC_CRP.fasta"
RESULT_DIR="analysis_results_$(date +%Y%m%d)"
LINCLUST_OUT="${RESULT_DIR}/linclust/crp_clust_temp"
TMP_DIR="linclust_tmp"
THREADS=${SLURM_CPUS_PER_TASK:-48}
MIN_SEQ_ID=0.3
COVERAGE=0.6
COV_MODE=1

mkdir -p logs
mkdir -p "${RESULT_DIR}/linclust"
mkdir -p "$TMP_DIR"


$MMSEQS easy-linclust \
    "$INPUT_FASTA" \
    "$LINCLUST_OUT" \
    "$TMP_DIR" \
    --threads "$THREADS" \
    --min-seq-id "$MIN_SEQ_ID" \
    -c "$COVERAGE" \
    --cov-mode "$COV_MODE" \
    -v 3 # 详细程度 (1: errors, 2: warnings, 3: infos)

# 统计聚类后的代表序列数量
if [[ -f "${LINCLUST_OUT}_rep_seq.fasta" ]]; then
    rep_count=$(grep -c "^>" "${LINCLUST_OUT}_rep_seq.fasta")
    raw_count=$(grep -c "^>" "$INPUT_FASTA")
    echo "[$(date)] SUMMARY: Raw sequences: $raw_count"
    echo "[$(date)] SUMMARY: Representative sequences: $rep_count"
    echo "[$(date)] SUMMARY: Compression ratio: $(awk "BEGIN {print $rep_count/$raw_count}")"
fi

# rm -rf "$TMP_DIR"

echo "[$(date)] INFO: All tasks finished successfully."

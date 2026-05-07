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

# 1. 环境准备
module load esm-fold
module load cuda
# 必须设置 APPTAINER_NV 为 true 以使用 GPU
export APPTAINER_NV=true

# 关键：必须绑定你的文件系统路径，否则容器内找不到 /filer-5
# 这里建议绑定整个 /filer-5 目录
export APPTAINER_BIND="/filer-5:/filer-5"

# 2. 定义路径
# 请检查你的输入文件路径是否正确
INPUT_FASTA="/filer-5/user/tan/protein/zcct1_56_aa.fa"
OUTPUT_DIR="/filer-5/user/tan/protein/zcct1_56_aa"
export TORCH_HOME="/filer-5/agruppen/PBP/tan/software/esmfold"
mkdir -p ${OUTPUT_DIR}

# 3. 执行 ESM-Fold 预测
# 使用管理员定义的变量 ${ESMFOLD_CONTAINER} 来启动容器
# -i 输入 fasta, -o 输出目录
date
echo "Starting ESM-Fold prediction"

${ESMFOLD_CONTAINER} \
  -i ${INPUT_FASTA} \
  -o ${OUTPUT_DIR}

echo "Prediction finished."
date


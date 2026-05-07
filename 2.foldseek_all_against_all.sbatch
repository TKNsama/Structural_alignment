#!/bin/bash
#SBATCH --job-name=foldseek
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

module load foldseek

# 1. 进入你的 PDB 文件夹
cd /filer-5/user/tan/protein/zcct1_56_aa

# 2. 创建 Foldseek 数据库
foldseek createdb . ../pep_db

# 3. 运行 All-against-all 比对
# --alignment-type 1: 使用 3Di+AA 混合比对
# --tmscore-threshold 0.0: 我们需要所有 pair 的得分（或者设为 0.3 过滤掉完全不相关的）
# -a: 计算并输出比对结果
foldseek search ../pep_db ../pep_db ../all_vs_all_res ../tmp \
    --alignment-type 1 \
    -a 1 \
    --threads 16 \
    --tmscore-threshold 0.3

# 4. 导出为易读的 TAB 格式
# query, target, alntmscore (这是 Foldseek 估算的 TM-score)
foldseek convertalis ../pep_db ../pep_db ../all_vs_all_res ../all_vs_all.tab \
    --format-output "query,target,alntmscore,rmsd,lddt,fident,alnlen,evalue"



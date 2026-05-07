### Protein Structural Space Analysis Workflow

## step0: use mmseq2 to cluster similar sequence and get represent sequence `seqclust`. (based on Sequence)
## step1: use esmfold to predicted `linclust` sequence, map other sequence to `seqclust`. 
## step2: use foldseek to cluster all the pdb files of `seqclust`, get the `proclust`. (based on pridected Protein strucure)
## step3: use foldseek to alignment all agasin all of `seqclust`, then transfer into matrix. 
## step4: UMAP clustering.


这是一个用于蛋白质结构分析的自动化流水线，涵盖了从序列预测到结构空间可视化的完整流程。

## 📁 流程概览

1.  **ESM-Fold**: 预测氨基酸序列的三维结构。
2.  **Foldseek**: 进行全对全（All-against-all）结构比对。
3.  **Matrix Conversion**: 将比对得分转换为距离矩阵。
4.  **UMAP Visualization**: 降维并在二维空间中展示结构聚类。

---

## 🛠 脚本说明

### 1. 结构预测 (`1.esmfold.sbatch`)
使用 Meta 开发的 ESM-Fold 模型，在 GPU 节点上高速预测 PDB 结构。
- **输入**: `zcct1_56_aa.fa`
- **输出**: `zcct1_56_aa/` 目录下的 PDB 文件。

### 2. 结构比对 (`2.foldseek_all_against_all.sbatch`)
利用 Foldseek 强大的结构搜索能力计算 TM-score。
- **关键参数**: `--alignment-type 1` (3Di+AA 混合模式), `--tmscore-threshold 0.3`。
- **输出**: `all_vs_all.tab`。

### 3. 矩阵转换 (`3.foldseek_all_against_all2matrix.py`)
Python 脚本，用于处理 Foldseek 输出并生成方阵。
- **逻辑**: 将 TM-score 转换为距离 ($Distance = 1 - TMscore$)。
- **处理**: 自动处理数据类型，补全缺失 pair，确保矩阵对称化。
- **输出**: `crp_structural_dist_matrix.csv`。

### 4. 降维可视化 (`4.UMAP.R`)
R 脚本，使用 UMAP 算法对结构距离进行流形学习。
- **特性**: 生成 PDF 图片，包含每个点的 ID 标注。
- **输出**: `UMAP_structural_space_labeled.pdf`。

---

## 🚀 快速开始

### 集群提交任务
```bash
# 运行 ESM-Fold 预测
sbatch 1.esmfold.sbatch

# 运行 Foldseek 比对
sbatch 2.foldseek_all_against_all.sbatch"""# Protein Structural Space Analysis Workflow

这是一个用于蛋白质结构分析的自动化流水线，涵盖了从序列预测到结构空间可视化的完整流程。

## 📁 流程概览

1.  **ESM-Fold**: 预测氨基酸序列的三维结构。
2.  **Foldseek**: 进行全对全（All-against-all）结构比对。
3.  **Matrix Conversion**: 将比对得分转换为距离矩阵。
4.  **UMAP Visualization**: 降维并在二维空间中展示结构聚类。

---

## 🛠 脚本说明

### 1. 结构预测 (`1.esmfold.sbatch`)
使用 Meta 开发的 ESM-Fold 模型，在 GPU 节点上高速预测 PDB 结构。
- **输入**: `zcct1_56_aa.fa`
- **输出**: `zcct1_56_aa/` 目录下的 PDB 文件。

### 2. 结构比对 (`2.foldseek_all_against_all.sbatch`)
利用 Foldseek 强大的结构搜索能力计算 TM-score。
- **关键参数**: `--alignment-type 1` (3Di+AA 混合模式), `--tmscore-threshold 0.3`。
- **输出**: `all_vs_all.tab`。

### 3. 矩阵转换 (`3.foldseek_all_against_all2matrix.py`)
Python 脚本，用于处理 Foldseek 输出并生成方阵。
- **逻辑**: 将 TM-score 转换为距离 ($Distance = 1 - TMscore$)。
- **处理**: 自动处理数据类型，补全缺失 pair，确保矩阵对称化。
- **输出**: `crp_structural_dist_matrix.csv`。

### 4. 降维可视化 (`4.UMAP.R`)
R 脚本，使用 UMAP 算法对结构距离进行流形学习。
- **特性**: 生成 PDF 图片，包含每个点的 ID 标注。
- **输出**: `UMAP_structural_space_labeled.pdf`。

---

## 🚀 快速开始

### 集群提交任务
```bash
# 运行 ESM-Fold 预测
sbatch 1.esmfold.sbatch

# 运行 Foldseek 比对
sbatch 2.foldseek_all_against_all.sbatch

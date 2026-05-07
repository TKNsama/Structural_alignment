import pandas as pd
import numpy as np

# 1. 读取 Foldseek 输出
print("Loading Foldseek results...")
df = pd.read_csv('all_vs_all.tab', sep='\t', names=['query', 'target', 'tmscore'])

# 2. 转换为透视表 (Pivot Table)
# 这一步会将数据排列成矩阵格式
print("Pivoting data into matrix...")
matrix = df.pivot(index='query', columns='target', values='tmscore')

# 3. 矩阵清理
# 由于 Foldseek search 可能只保留了高分结果，缺失值填 0
matrix = matrix.fillna(0)

# 确保矩阵是完全对称的 (A vs B 应该等于 B vs A)
# 取矩阵与其转置的最大值
matrix = np.maximum(matrix, matrix.transpose())

# 4. 转换为距离矩阵 (Distance = 1 - Similarity)
dist_matrix = 1 - matrix

# 5. 保存结果供 UMAP 使用
dist_matrix.to_csv('crp_structural_dist_matrix.csv')
print(f"Matrix shape: {dist_matrix.shape}")


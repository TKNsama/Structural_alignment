import pandas as pd
import numpy as np

# 1. 明确读取 query, target 和 alntmscore (第 1, 2, 3 列)
print("Loading Foldseek results...")
# usecols=[0, 1, 2] 对应 query, target, alntmscore
df = pd.read_csv('all_vs_all.tab', 
                 sep='\t', 
                 usecols=[0, 1, 2], 
                 names=['query', 'target', 'tmscore'],
                 dtype={'query': str, 'target': str, 'tmscore': float})

# 2. 转换为矩阵
print("Pivoting data into matrix...")
# 使用 pivot_table 处理可能存在的重复比对，取 TM-score 最大值
matrix = df.pivot_table(index='query', columns='target', values='tmscore', aggfunc='max')

# 3. 补全方阵
# Foldseek 的 all-vs-all 有时 A-B 存在但 B-A 因为阈值被过滤，需要补齐
matrix = matrix.fillna(0)
all_ids = sorted(list(set(matrix.index) | set(matrix.columns)))
matrix = matrix.reindex(index=all_ids, columns=all_ids, fill_value=0)

# 4. 对称化 (Symmetry)
# 确保 A vs B 和 B vs A 的分数一致
print("Symmetrizing matrix...")
matrix = np.maximum(matrix, matrix.transpose())

# 5. 转换为距离矩阵 (1 - TMscore)
dist_matrix = 1 - matrix

# 6. 保存
dist_matrix.to_csv('crp_structural_dist_matrix.csv', index=True)
print(f"Matrix saved! Final shape: {dist_matrix.shape}")


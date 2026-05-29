import pandas as pd
import numpy as np

print("Loading Foldseek results...")
df = pd.read_csv('all_vs_all.tab', sep='\t', names=['query', 'target', 'tmscore'])

print("Pivoting data into matrix...")
matrix = df.pivot(index='query', columns='target', values='tmscore')

matrix = matrix.fillna(0)

matrix = np.maximum(matrix, matrix.transpose())

# To distance martix (Distance = 1 - Similarity)
dist_matrix = 1 - matrix

dist_matrix.to_csv('crp_structural_dist_matrix.csv')
print(f"Matrix shape: {dist_matrix.shape}")

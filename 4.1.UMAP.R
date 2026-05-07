library(umap)
library(dplyr)
library(ggplot2)
library(ggrepel)  # 用于更美观的标签排列

# =========================
# 1. 读取数据
# =========================
# 路径建议使用相对路径或确认绝对路径正确
df <- read.csv("/filer-5/user/tan/protein/crp_structural_dist_matrix.csv")

rownames(df) <- df[,1]
dist_mat <- as.matrix(df[,-1])

# =========================
# 2. UMAP 计算
# =========================
set.seed(100)
config <- umap.defaults
config$n_neighbors <- 30
config$min_dist <- 0.5
config$input <- "dist"

umap_res <- umap(dist_mat, config = config)

# 准备绘图数据
plot_data <- data.frame(
  ID = rownames(dist_mat),
  U1 = umap_res$layout[,1],
  U2 = umap_res$layout[,2]
) 


# =========================
# 3. 绘图与保存
# =========================
# 在 Linux 下必须指定输出文件设备
pdf("UMAP_structural_space_labeled.pdf", width = 10, height = 8)

p_umap <- ggplot(plot_data, aes(U1, U2)) +
  geom_point(alpha = 0.6, size = 1.5, color = "black") +
  # 添加标签：check_overlap = TRUE 防止标签太密导致黑成一团
  # 如果点不多，推荐用 geom_text_repel()
  geom_text(aes(label = ID), vjust = 1.5, size = 2, check_overlap = TRUE) + 
  theme_bw(base_size = 14) +
  labs(
    title = "UMAP of Protein Structural Space",
    subtitle = "Labeled by Protein ID (Overlaps hidden)",
    x = "UMAP1", y = "UMAP2"
  )

print(p_umap)
dev.off() # 关闭设备，完成写入

cat("Success: UMAP plot saved to UMAP_structural_space_labeled.png\n")

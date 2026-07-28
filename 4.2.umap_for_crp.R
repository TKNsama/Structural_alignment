library(umap)
library(tidyverse)
library(RColorBrewer)
library(ggrepel)
library(data.table)

BASE_DIR <- Sys.getenv("BASE_DIR", unset = "/filer-5/agruppen/PBP/tan")

setwd("U:/project/evolution_of_CRP_new/protein_cluster/")

df <- read.csv("//filer-5/user/tan/evolution/crp/new/alphafold_barley/crp_structural_dist_matrix.csv",header = T)

# 1. 读取距离矩阵 (假设第一列是 Protein_ID)
dist_mat_raw <- df
rownames(dist_mat_raw) <- dist_mat_raw[, 1]
dist_mat <- as.matrix(dist_mat_raw[, -1])

# 2. 读取特征文件 (记录了 Cluster, Family, pLDDT, Size 等)
meta_data <- read.csv("clipboard",sep = "\t")

# 3. 设置 UMAP 参数
# n_neighbors: 决定了关注局部还是全局结构（建议 15-30）
# min_dist: 控制点的紧密程度（建议 0.1-0.5）
set.seed(100)
custom_config <- umap.defaults
custom_config$n_neighbors <- 30
custom_config$min_dist <- 0.5
custom_config$input <- "dist" # 重要：告诉 UMAP 输入的是距离

# 4. 执行降维
print("Running UMAP...")
umap_results <- umap(dist_mat, config = custom_config)

# 5. 合并降维坐标与特征数据
plot_data <- data.frame(
  ID = rownames(umap_results$layout),
  U1 = umap_results$layout[, 1],
  U2 = umap_results$layout[, 2]
) %>%
  left_join(meta_data, by = c("ID" = "Row.Labels")) # 确保 ID 对应

library(ggplot2)

# 1. 定义颜色向量 (包含 16 个高对比度颜色 + Other/NA 的灰色)
# 这里的颜色经过挑选，即使在点很多的情况下也能保持区分度
my_colors <- c(
  "Major_Superfamilies_C1"  = "#E41A1C", # 鲜红
  "Major_Superfamilies_C2"  = "#377EB8", # 亮蓝
  "Major_Superfamilies_C3"  = "#4DAF4A", # 翠绿
  "Major_Superfamilies_C4"  = "#984EA3", # 紫罗兰
  "Major_Superfamilies_C5"  = "#FF7F00", # 橙色
  "Major_Superfamilies_C6"  = "#FFFF33", # 明黄
  "Major_Superfamilies_C7"  = "#A65628", # 赭石
  "Major_Superfamilies_C8"  = "#F781BF", # 桃粉
  "Major_Superfamilies_C9"  = "black", # 深灰
  "Major_Superfamilies_C10" = "#66C2A5", # 薄荷绿
  "Major_Superfamilies_C11" = "#FC8D62", # 珊瑚色
  "Major_Superfamilies_C12" = "#8DA0CB", # 灰蓝
  "Major_Superfamilies_C13" = "#E78AC3", # 浅紫红
  "Major_Superfamilies_C14" = "#A6D854", # 黄绿
  "Major_Superfamilies_C15" = "#FFD92F", # 金色
  "Other"                   = "#D3D3D3"  # 浅灰色 (重点)
)

# 2. 绘图代码
# 定义对应的形状映射
my_shapes <- c(
  "Brassicaceae specific" = 17,    # 假设这是你的分类名：三角形
  "Poaceae specific" = 15     # 假设这是另一个分类：正方形
)

ggplot() +
  # 1. 背景点 (灰色)
  geom_point(data = filter(plot_data, Class == "Other" | is.na(Class)),
             aes(x = U1, y = U2), color = "grey80", size = 1, alpha = 0.5) +

  # 2. 彩色核心家族点 (圆形)
  geom_point(data = filter(plot_data, Class != "Other" & !is.na(Class)),
             aes(x = U1, y = U2, color = Class, size = Count_log), alpha = 0.6) +

  # 3. 关键分类点 (强制指定形状，并略微放大以突出显示)
  geom_point(data = filter(plot_data, Taxonomic.Distribution != "Common or Other species specific" & !is.na(Taxonomic.Distribution)),
             aes(x = U1, y = U2, shape = Taxonomic.Distribution),
             alpha = 0.5,
             size = 1.5) + # 形状的 size 建议比背景点大

  # 颜色和形状的映射
  scale_color_manual(values = my_colors, na.value = "#E0E0E0") +
  scale_shape_manual(values = my_shapes) +

  theme_bw(base_size = 14,base_line_size = 1,base_rect_size = 1) +
  # 优化图例，让形状在图例里更清晰
  guides(
    color = guide_legend(override.aes = list(alpha = 1, size = 4), ncol = 2),
    shape = guide_legend(override.aes = list(size = 5))
  ) +
  labs(
    title = "Structural Landscape of CRP Families",
    subtitle = "Triangles and Squares highlight species-specific expansions",
    shape = "Taxonomic Distribution"
  ) +
  theme(
    legend.position = "right",
    panel.grid.minor = element_blank()
  )



zoom_color <- c("EF_C89" = "red")

library(dplyr)
library(ggplot2)

library(dplyr)

# 目标 cluster
target <- plot_data %>%
  filter(Class == "EF_C89")

# 计算中心
center <- target %>%
  summarise(U1 = mean(U1), U2 = mean(U2))

# 计算所有点到中心的欧氏距离
plot_data$dist_to_C267 <- sqrt(
  (plot_data$U1 - center$U1)^2 +
    (plot_data$U2 - center$U2)^2
)

threshold <- quantile(plot_data$dist_to_C267, 0.05)

nearby_classes <- plot_data %>%
  filter(dist_to_C267 <= threshold) %>%
  pull(Class) %>%
  unique()

nearby_classes

library(ggrepel)

plot_data$neighborhood <- ifelse(
  plot_data$Class %in% nearby_classes,
  "neighbor",
  "other"
)

plot_data$target <- ifelse(
  plot_data$Class == "Emerging_families_C267",
  "C267",
  plot_data$neighborhood
)

library(ggplot2)

ggplot(plot_data, aes(U1, U2)) +

  # background
  geom_point(mapping = aes(colour = sClass), size = 0.5) +

#  # neighbors
#  geom_point(
#    data = subset(plot_data, neighborhood == "neighbor"),
#    aes(color = Class),
#    size = 0.8
#  ) +

  # C267 itself
  geom_point(
    data = subset(plot_data, Class == "EF_C89"),
    color = "black",shape = 21, fill = "green2",
    size = 2
  ) +
  scale_color_manual(values = c("EF" = "#e7b800","MS" = "#e64b35","SF" = "#4dbbd5")) +
  theme_bw(base_size = 14,base_line_size = 1,base_rect_size = 1)


library(ggplot2)
library(dplyr)
#EF_C93
#EF_c89
# =========================
# 1. 定义 C267 index
# =========================
idx <- which(plot_data$Class.1 == "EF_C59")[1]

# =========================
# 2. kNN（你已经算过，这里重复保证完整）
# =========================
library(FNN)
knn <- get.knn(plot_data[, c("U1", "U2")], k = 1000)

neighbors <- knn$nn.index[idx, ]

# =========================
# 3. 提取 zoom 数据
# =========================
zoom_data <- plot_data %>%
  mutate(group = ifelse(Class.1 == "Emerging_families_C59",
                        "EF_C59",
                        "neighbor"))

# =========================
# 4. 画 zoom 图
# =========================

ggplot(zoom_data, aes(U1, U2,colour = bigfamily)) +

  # neighbors
  geom_point(
    data = subset(zoom_data, group == "neighbor"),
    #color = "grey60",
    size = 1.2
  ) +
  scale_color_manual(values = c("Emerging_families" = "#e7b800","Major_Superfamilies" = "#e64b35","Sub_families" = "#4dbbd5")) +

  # C267
  geom_point(
    data = subset(zoom_data, group == "EF_C59"),
    color = "green",
    size = 4
  ) +

  theme_bw(base_size = 14,base_line_size = 1,base_rect_size = 1) +

  labs(
    title = "Zoom-in view of Emerging_families_C267 neighborhood",
    x = "UMAP1",
    y = "UMAP2"
  )




library(ggplot2)
library(dplyr)
library(ggrepel)

# =========================
# 1. 计算每个 Class 的中心（只针对邻域）
# =========================
label_data <- zoom_data %>%
  filter(group == "neighbor") %>%
  group_by(Class) %>%
  summarise(
    U1 = mean(U1),
    U2 = mean(U2),
    .groups = "drop"
  )

# =========================
# 2. 作图
# =========================
ggplot(plot_data, aes(U1, U2, colour = bigfamily)) +

  # neighbors
  geom_point(
    data = subset(plot_data, type == "Other"),
    size = 1.2
  ) +

  # C267
  geom_point(
    data = subset(plot_data, type == "PNI1"),
    color = "yellow",
    size = 2.5
  ) +
  geom_point(
    data = subset(plot_data, type == "CRP"),
    color = "pink",
    size = 2.5
  ) +
  geom_point(
    data = subset(plot_data, type == "CGRP"),
    color = "blue",
    size = 2.5
  ) +

  scale_color_manual(values = c("Emerging_families" = "#e7b800","Major_Superfamilies" = "#e64b35","Sub_families" = "#4dbbd5")) +

  theme_bw(base_size = 14, base_line_size = 1, base_rect_size = 1) +

  labs(
    title = "Zoom-in view of Emerging_families_C267 neighborhood",
    x = "UMAP1",
    y = "UMAP2"
  )


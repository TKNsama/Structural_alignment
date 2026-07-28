library(umap)
library(dplyr)
library(ggplot2)
library(ggrepel)

BASE_DIR <- Sys.getenv("BASE_DIR", unset = "/filer-5/agruppen/PBP/tan")

df <- read.csv("/filer-5/user/tan/protein/crp_structural_dist_matrix.csv")

rownames(df) <- df[,1]
dist_mat <- as.matrix(df[,-1])

set.seed(100)
config <- umap.defaults
config$n_neighbors <- 30
config$min_dist <- 0.5
config$input <- "dist"

umap_res <- umap(dist_mat, config = config)

plot_data <- data.frame(
  ID = rownames(dist_mat),
  U1 = umap_res$layout[,1],
  U2 = umap_res$layout[,2]
) 


pdf("UMAP_structural_space_labeled.pdf", width = 10, height = 8)

p_umap <- ggplot(plot_data, aes(U1, U2)) +
  geom_point(alpha = 0.6, size = 1.5, color = "black") +
  geom_text(aes(label = ID), vjust = 1.5, size = 2, check_overlap = TRUE) + 
  theme_bw(base_size = 14) +
  labs(
    title = "UMAP of Protein Structural Space",
    subtitle = "Labeled by Protein ID (Overlaps hidden)",
    x = "UMAP1", y = "UMAP2"
  )

print(p_umap)
dev.off() 

cat("Success: UMAP plot saved to UMAP_structural_space_labeled.png\n")

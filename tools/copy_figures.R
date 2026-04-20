# =========================================================================
# FILE: tools/copy_figures.R
# DESCRIPTION: ターゲット内の外部画像群を一時的にルートディレクトリに退避させるLaTeXビルド用事前処理フック
# =========================================================================

# -------------------------------------------------------------------------
# 1. ファイル階層の解析および転送
# -------------------------------------------------------------------------
library(yaml)

quarto_config <- read_yaml("_quarto.yml")
settings <- quarto_config$`user-settings`

if (!is.null(settings) && !is.null(settings$figure_dir)) {
  fig_dir <- settings$figure_dir
  if (dir.exists(fig_dir)) {
    files <- list.files(fig_dir, full.names = TRUE)
    for (f in files) {
      if (!dir.exists(f)) {
        # プロジェクトルートにコピーして、LaTeXのフラットな参照 (\includegraphics{file.png}) を可能にする
        file.copy(f, ".", overwrite = TRUE)
      }
    }
  }
}

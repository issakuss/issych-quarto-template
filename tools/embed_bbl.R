#!/usr/bin/env Rscript

# -------------------------------------------------------------------------
# embed_bbl.R
# Quartoのpost-renderにて発火し、embed_bblオプションがtrueのときのみ、
# ルートの .tex ファイル内にある \bibliography{} を .bbl の中身に置換する。
# -------------------------------------------------------------------------

library(yaml)

config_path <- "_quarto.yml"
if (!file.exists(config_path)) {
  message("Warning: _quarto.yml not found. Skipping bbl embedding.")
  quit(save = "no", status = 0)
}

config <- tryCatch(yaml::read_yaml(config_path), error = function(e) list())

embed_flag <- config$`user-settings`$embed_bbl
if (!is.null(embed_flag) && isTRUE(embed_flag)) {
  message("Embedding .bbl into .tex (embed_bbl is TRUE)...")
  
  # ルートディレクトリの .tex ファイルを探す
  tex_files <- list.files(pattern = "\\.tex$")
  
  for (tex_file in tex_files) {
    bbl_file <- sub("\\.tex$", ".bbl", tex_file)
    
    if (file.exists(bbl_file)) {
      tex_content <- readLines(tex_file, warn = FALSE)
      bbl_content <- readLines(bbl_file, warn = FALSE)
      
      # \bibliography{...} と \bibliographystyle{...} の行を検索
      bib_idx <- grep("^\\\\bibliography\\{", tex_content)
      style_idx <- grep("^\\\\bibliographystyle\\{", tex_content)
      
      if (length(bib_idx) > 0) {
        # \bibliography の行を .bbl の中身で丸ごと置換する
        tex_content[bib_idx[1]] <- paste(bbl_content, collapse = "\n")
        
        # 複数ある場合は残りを削除、\bibliographystyle も削除
        lines_to_remove <- c(bib_idx[-1], style_idx)
        if (length(lines_to_remove) > 0) {
          tex_content <- tex_content[-lines_to_remove]
        }
        
        writeLines(tex_content, tex_file)
        message(sprintf("Successfully embedded [%s] into [%s]", bbl_file, tex_file))
      } else {
        message(sprintf("No \\bibliography{...} found in [%s]. Skipping.", tex_file))
      }
    }
  }
} else {
  message("Skipping .bbl embedding (embed_bbl is FALSE or not set)")
}

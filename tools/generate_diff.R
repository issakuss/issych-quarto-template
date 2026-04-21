#!/usr/bin/env Rscript

# -------------------------------------------------------------------------
# generate_diff.R
# Quartoのpost-renderにて発火し、diff_targetが指定されている場合のみ
# tex-source-files/ 以下の .tex ファイルと古いコミットとの latexdiff を生成する。
# -------------------------------------------------------------------------

library(yaml)

config_path <- "_quarto.yml"
if (!file.exists(config_path)) {
  quit(save = "no", status = 0)
}

config <- tryCatch(yaml::read_yaml(config_path), error = function(e) list())

diff_target <- config$`user-settings`$diff_target

if (is.null(diff_target) || trimws(diff_target) == "") {
  message("Skipping latexdiff: diff_target is empty or not set.")
  quit(save = "no", status = 0)
}

message(sprintf("Running latexdiff against [%s]...", diff_target))

# すべての作業は tex-source-files 内で行う
# .clsや.bib、.bstなどのリソースも揃っているため遅延なくコンパイルできる
src_dir <- "tex-source-files"
if (!dir.exists(src_dir)) {
  message("Warning: tex-source-files/ directory not found. Skipping latexdiff.")
  quit(save = "no", status = 0)
}

# ルートディレクトリでRが実行されているため、対象ディレクトリに移動する
cwd <- getwd()
setwd(src_dir)

tex_files <- list.files(pattern = "^[^diff-].*\\.tex$") # diffから始まらないtexファイル

for (tex_file in tex_files) {
  basename_no_ext <- sub("\\.tex$", "", tex_file)
  diff_tex_name <- sprintf("diff-%s", tex_file)
  old_tex_name <- sprintf("old_%s", tex_file)
  diff_pdf_name <- sprintf("diff-%s.pdf", basename_no_ext)
  
  # git から旧バージョンを取得（旧ファイルは tex/ 配下に格納されていた前提）
  git_cmd <- sprintf("git show %s:tex/%s > %s 2>/dev/null", diff_target, tex_file, old_tex_name)
  sys_res <- system(git_cmd)
  
  if (sys_res != 0 || file.info(old_tex_name)$size == 0) {
    message(sprintf("Warning: Could not fetch old version of [%s] from commit [%s]. Skipping.", tex_file, diff_target))
    if (file.exists(old_tex_name)) file.remove(old_tex_name)
    next
  }
  
  # latexdiffの実行
  ld_cmd <- sprintf('latexdiff --config="PICTUREENV=(?:picture|tikzpicture|thebibliography|longtable)" %s %s > %s', old_tex_name, tex_file, diff_tex_name)
  system(ld_cmd)
  
  # LuaLaTeXでコンパイル (3回回す＋途中でbibtex)
  # diffファイルは最終的にtex-source-files/に残すため、出力ディレクトリはこのまま
  system(sprintf("lualatex -interaction=nonstopmode %s", diff_tex_name))
  system(sprintf("bibtex diff-%s", basename_no_ext))
  system(sprintf("lualatex -interaction=nonstopmode %s", diff_tex_name))
  system(sprintf("lualatex -interaction=nonstopmode %s", diff_tex_name))
  
  # 生成されたPDFをルートへコピー（diff.tex等はtex-source-filesに残る）
  if (file.exists(diff_pdf_name)) {
    file.copy(diff_pdf_name, file.path("..", diff_pdf_name), overwrite = TRUE)
    message(sprintf("Successfully generated diff PDF: root/%s", diff_pdf_name))
  } else {
    message(sprintf("Failed to generate diff PDF for [%s]", tex_file))
  }
  
  # 古いファイルと中間ファイルのクリーンアップ
  # diff-xxx.texとdiff-xxx.pdfはtex-source-files内に保持する
  if (file.exists(old_tex_name)) file.remove(old_tex_name)
  
  # latexの中間ファイル(diff用のもの)を消去
  # tex-source-files/ を必要以上に汚さないため
  interim_exts <- c("aux", "bbl", "blg", "log", "out", "fls", "fdb_latexmk")
  for (ext in interim_exts) {
    f <- sprintf("diff-%s.%s", basename_no_ext, ext)
    if (file.exists(f)) file.remove(f)
  }
}

setwd(cwd)
message("latexdiff generation completed.")

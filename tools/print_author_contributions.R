# =========================================================================
# FILE: tools/print_author_contributions.R
# DESCRIPTION: YAMLフロントマターから著者情報を解析し、貢献度をリスト展開します
# =========================================================================

# -------------------------------------------------------------------------
# 1. 著者役割の展開マクロ
# -------------------------------------------------------------------------
print_author_contributions <- function() {
  # 現在knitrで処理中のファイル名を取得します（指定がない場合は manuscript.qmd にフォールバックします）
  current_doc <- knitr::current_input()
  if (is.null(current_doc)) {
    current_doc <- "manuscript.qmd"
  }
  
  # ファイルを読み込み "---" で囲まれたフロントマターを抽出します
  lines <- readLines(current_doc)
  yaml_end_idx <- which(lines == "---")[2]
  
  if (!is.na(yaml_end_idx) && yaml_end_idx > 2) {
    yaml_text <- paste(lines[2:(yaml_end_idx - 1)], collapse = "\n")
    ms_cfg <- yaml::yaml.load(yaml_text)
    
    # 著者リストから name と roles を抽出してMarkdown形式で出力します
    if (!is.null(ms_cfg$author)) {
      for (a in ms_cfg$author) {
        if (!is.null(a$roles) && length(a$roles) > 0) {
          cat(paste0("**", a$name, "**: ", paste(a$roles, collapse = ", "), ".  \n\n"))
        }
      }
    }
  }
}

# =========================================================================
# FILE: tools/read_csv_tables.R
# DESCRIPTION: CSVファイル群の読み込み、書式フォーマット化、およびテーブル出力専用関数
# =========================================================================

# -------------------------------------------------------------------------
# 1. 依存パッケージとユーティリティ宣言
# -------------------------------------------------------------------------
library(kableExtra)

# テーブルデータの列名に含まれる `!Type` アノテーションを読み取り、
# YAMLと同じ変換ロジックでデータフレーム全体を一括フォーマットする関数
format_table <- function(df) {
  col_names <- colnames(df)
  new_df <- df
  new_names <- character(length(col_names))
  index_cols <- c()
  
  for (i in seq_along(col_names)) {
    orig_name <- col_names[i]
    if (grepl("!", orig_name, fixed = TRUE)) {
      # "!"で分割
      parts <- strsplit(orig_name, "!", fixed = TRUE)[[1]]
      name_part <- parts[1] # 例: orig_name=="!Str" の時は "" になる
      type_part <- parts[2]
      
      if (type_part == "iqIndex") {
        index_cols <- c(index_cols, i)
      }
      
      new_names[i] <- name_part
      
      # 型ハンドラが存在すれば列全体にベクタライズ適用、なければ文字列化
      if (type_part %in% names(table_handlers)) {
        new_df[[i]] <- table_handlers[[type_part]](df[[i]])
      } else {
        new_df[[i]] <- as.character(df[[i]])
      }
    } else {
      # 型指定がない場合はデフォルトの文字列として扱う
      new_names[i] <- orig_name
      new_df[[i]] <- as.character(df[[i]])
    }
  }
  colnames(new_df) <- apply_abbreviations(new_names)
  attr(new_df, "index_cols") <- index_cols
  return(new_df)
}

# -------------------------------------------------------------------------
# 2. Markdown/LaTeX 描画ラッパー
# -------------------------------------------------------------------------
make_table <- function(df, note = NULL) {
  idx_cols <- attr(df, "index_cols")
  
  if (!is.null(idx_cols) && length(idx_cols) > 0) {
    out <- kbl(df, booktabs = TRUE, escape = FALSE) |>
      collapse_rows(columns = idx_cols, valign = "top", latex_hline = "none")
  } else {
    out <- kbl(df, booktabs = TRUE, escape = FALSE)
  }
  
  if (!is.null(note)) {
    # 3パートテーブルとしてfootnoteを追加（escape=FALSEでLaTeX記法を通す）
    out <- out |> footnote(general = note, threeparttable = TRUE, escape = FALSE)
  }
  
  return(out)
}

# -------------------------------------------------------------------------
# 3. 指定ディレクトリからのデータ走査とマウント
# -------------------------------------------------------------------------
tbl_dir <- ifelse(!is.null(settings$table_dir), settings$table_dir, "sample_data/table")

if (dir.exists(tbl_dir)) {
  csv_files <- list.files(tbl_dir, pattern = "\\.csv$", full.names = TRUE)
  for (csv_file in csv_files) {
    df_raw <- read.csv(csv_file, check.names = FALSE)
    df_fmt <- format_table(df_raw)
    
    # 拡張子を除いたファイル名を変数名とする (例: "table_data.csv" -> "table_data")
    var_name <- tools::file_path_sans_ext(basename(csv_file))
    assign(var_name, df_fmt, envir = .GlobalEnv)
  }
}

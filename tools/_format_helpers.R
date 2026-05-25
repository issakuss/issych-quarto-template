# =========================================================================
# FILE: tools/_format_helpers.R
# DESCRIPTION: データ型変換や文字列成形のための共通ユーティリティ関数群
# =========================================================================

# -------------------------------------------------------------------------
# 1. 自動置換および文字列エスケープ
# -------------------------------------------------------------------------
# abbreviations に基づく文字列の完全一致置換ヘルパー
# kableExtra で escape=FALSE を使用するため、置換されない生の変数名に含まれる
# LaTeX予約語（特に "_"）を安全にエスケープする処理も兼ね備えます
apply_abbreviations <- function(x) {
  res <- x
  for (i in seq_along(x)) {
    orig_val <- x[i]
    if (!is.null(abbreviations) && orig_val %in% names(abbreviations)) {
      res[i] <- as.character(abbreviations[[orig_val]])
    } else {
      # 未定義の変数名に含まれる `_` などのLaTeXエラー原因を保護
      res[i] <- gsub("_", "\\\\_", orig_val)
    }
  }
  return(res)
}

# 文頭などに埋め込む際、文字列の最初の文字を大文字にするためのヘルパー関数
# 例: `r Cap(res$demographics$some_small_int)` -> "Seven"
Cap <- function(x) {
  x <- as.character(x)
  if (length(x) > 0 && nchar(x[1]) > 0) {
    substr(x[1], 1, 1) <- toupper(substr(x[1], 1, 1))
  }
  return(x)
}

# -------------------------------------------------------------------------
# 2. 数値フォーマットヘルパー
# -------------------------------------------------------------------------
# 整数を指定の基準値(under_limit)未満なら英単語にするヘルパー関数
# (english パッケージが必須です)
int_to_word <- function(val, under_limit) {
  # ベクトル対応 (sapplyで各要素を処理)
  sapply(val, function(v) {
    if (!is.na(v) && v < under_limit) {
      return(as.character(english::english(v)))
    }
    return(as.character(v))
  })
}

# 1.0を超えない値（比率や相関係数等）のフォーマット用関数
# 必要に応じて先頭の '0' を取り除く (0.49 -> .49, -0.023 -> -.023)
# sprintf および sub はRで標準的にベクタライズされています
format_ngto <- function(val, fmt, omit_zero) {
  num_val <- as.numeric(val)
  formatted <- sprintf(fmt, num_val)
  if (omit_zero) {
    # 正規表現で、文字列の先頭にある 0. または -0. の 0 を消去する
    formatted <- sub("^(-?)0\\.", "\\1.", formatted)
  }
  return(formatted)
}

# p値のフォーマット用関数
# ifelse を利用して完全なベクタライズ対応
format_pval <- function(val, fmt, min_val, omit_zero) {
  num_val <- as.numeric(val)
  formatted <- ifelse(
    !is.na(num_val) & num_val < min_val,
    paste("<", format(min_val, scientific = FALSE)),
    sprintf(fmt, num_val)
  )
  
  if (omit_zero) {
    # "= 0.032" -> "= .032", "< 0.001" -> "< .001" のように最初の '0.' を '.' に置換
    formatted <- sub("0\\.", ".", formatted)
  }
  return(formatted)
}

# -------------------------------------------------------------------------
# 3. YAML/Tableハンドラ定義
# -------------------------------------------------------------------------
# YAMLのカスタムタグに対する処理（ハンドラ）を定義します
my_handlers <- list(
  "iqFloat"   = function(x) { sprintf(fmt_float, as.numeric(x)) },
  "iqIntMean" = function(x) { sprintf(fmt_intmean, as.numeric(x)) },
  "iqInt"     = function(x) { int_to_word(as.integer(x), spell_out_under) },
  "iqNGTO"    = function(x) { format_ngto(x, fmt_ngto, omit_zero) },
  "iqPval"    = function(x) { format_pval(x, fmt_pval, min_pval, omit_zero) },
  "iqStr"     = function(x) { as.character(x) }
)

# テーブルフォーマット用の専用ハンドラ（「=」を出力しない等の微調整用）
table_handlers <- list(
  "iqFloat"   = function(x) { sprintf(fmt_float, as.numeric(x)) },
  "iqIntMean" = function(x) { sprintf(fmt_intmean, as.numeric(x)) },
  "iqInt"     = function(x) { int_to_word(as.integer(x), spell_out_under) },
  "iqNGTO"    = function(x) { format_ngto(x, fmt_ngto, omit_zero) },
  "iqPval"    = function(x) { format_pval(x, fmt_pval_table, min_pval, omit_zero) },
  "iqIndex"   = function(x) { apply_abbreviations(as.character(x)) },
  "iqStr"     = function(x) { apply_abbreviations(as.character(x)) }
)

# =========================================================================
# FILE: tools/_load_config.R
# DESCRIPTION: _quarto.ymlの設定解析およびシステム全体へのグローバル変数展開
# =========================================================================

# -------------------------------------------------------------------------
# 1. 依存パッケージとローカル設定
# -------------------------------------------------------------------------
library(yaml)

# -------------------------------------------------------------------------
# 2. user-settings.yaml から独自のカスタム設定を読み込む
# -------------------------------------------------------------------------
settings      <- read_yaml("user-settings.yaml")
abbreviations <- settings$abbreviations

# 安全なフォールバックを伴う設定値の抽出
float_digits   <- ifelse(!is.null(settings$float_digits), settings$float_digits, 2)
intmean_digits <- ifelse(!is.null(settings$intmean_digits), settings$intmean_digits, 1)
pval_digits    <- ifelse(!is.null(settings$pval_digits), settings$pval_digits, 3)
min_pval       <- ifelse(!is.null(settings$min_pval), as.numeric(settings$min_pval), 0.001)
ngto_digits    <- ifelse(!is.null(settings$ngto_digits), settings$ngto_digits, 3)
omit_zero      <- ifelse(!is.null(settings$omit_leading_zero), as.logical(settings$omit_leading_zero), TRUE)
spell_out_under<- ifelse(!is.null(settings$spell_out_ints_under), settings$spell_out_ints_under, 10)

# sprintf用のフォーマット文字列を動的に生成
fmt_float      <- sprintf("%%.%df", float_digits)
fmt_intmean    <- sprintf("%%.%df", intmean_digits)
fmt_pval       <- sprintf("= %%.%df", pval_digits)       # インライン(YAML)文章用
fmt_pval_table <- sprintf("%%.%df", pval_digits)         # テーブル出力用 (「=」が付かない)
fmt_ngto       <- sprintf("%%.%df", ngto_digits)

# =========================================================================
# FILE: tools/read_yaml_variables.R
# DESCRIPTION: results.yamlの読み込みおよび本文変数としての展開
# =========================================================================

# -------------------------------------------------------------------------
# 1. 分析結果変数のロードと初期化
# -------------------------------------------------------------------------
library(yaml)

# 外部スクリプトの分析結果(yaml)を読み込み、オブジェクト `res` として利用可能にします
results_file <- ifelse(!is.null(settings$results_file), settings$results_file, "sample_data/results.yaml")
res <- read_yaml(results_file, handlers = my_handlers)

# 「res$」を書かずに `demographics$` 等から直接呼べるよう、リストの最上位をグローバル環境に展開します
list2env(res, envir = .GlobalEnv)

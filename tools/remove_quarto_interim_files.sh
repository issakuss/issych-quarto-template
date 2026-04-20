#!/usr/bin/env bash

# このスクリプトは、存在する .qmd ファイルと同名の _files ディレクトリのみを安全に削除します
# （例: coverletter.qmd があれば、coverletter_files ディレクトリだけを削除する）

for qmd_file in *.qmd; do
  target_dir="${qmd_file%.qmd}_files"
  if [ -d "$target_dir" ]; then
    rm -rf "$target_dir"
  fi
done

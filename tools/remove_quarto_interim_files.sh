#!/usr/bin/env bash

# このスクリプトは、存在する .qmd ファイルと同名の _files ディレクトリのみを安全に削除します
# （例: coverletter.qmd があれば、coverletter_files ディレクトリだけを削除する）

for qmd_file in *.qmd; do
  target_dir="${qmd_file%.qmd}_files"
  if [ -d "$target_dir" ]; then
    rm -rf "$target_dir"
  fi
done

# latex-clean: false によってルートディレクトリに取り残された一時ファイルを削除
# move_tex_source_files.shですでに必要な.texや.bibは退避済みのため、安全に消去する
rm -f *.aux *.bbl *.blg *.log *.out *.fls *.fdb_latexmk *.synctex.gz *.lof *.lot *.toc

#!/usr/bin/env bash

# 1. 必要なディレクトリを作成
mkdir -p tex tex-source-files

# 3. texファイルはバージョン管理用の tex/ にコピーし、元ファイルは tex-source-files/ へ移動
for file in *.tex; do
  if [ -f "$file" ]; then
    cp "$file" tex/
    mv "$file" tex-source-files/
  fi
done

# 4. その他のLaTeX補助ファイル(cls, spl, bst)は投稿用の tex-source-files/ のみに移動
for ext in cls spl bst; do
  for file in *.$ext; do
    if [ -f "$file" ]; then
      mv "$file" tex-source-files/
    fi
  done
done

# 5. 参考文献ファイル(.bib)も投稿システムで必要となるためコピー
for file in *.bib; do
  if [ -f "$file" ]; then
    cp "$file" tex-source-files/
  fi
done

# 6. pre-renderでルートディレクトリに一時コピーされた画像ファイルを tex-source-files/ に回収する
FIGURE_DIR=$(Rscript -e 'cat(yaml::read_yaml("_quarto.yml")$"user-settings"$"figure_dir")' 2>/dev/null)
if [ -n "$FIGURE_DIR" ] && [ -d "$FIGURE_DIR" ]; then
  for file in "$FIGURE_DIR"/*; do
    if [ -f "$file" ]; then
      # basename を取り出し、現在カレントディレクトリにある同名ファイルを移動する
      filename=$(basename "$file")
      if [ -f "$filename" ]; then
        mv "$filename" tex-source-files/
      fi
    fi
  done
fi

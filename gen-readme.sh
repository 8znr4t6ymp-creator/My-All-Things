#!/bin/bash
REPO="8znr4t6ymp-creator/My-All-Things"
BRANCH="main"

# 获取仓库根目录
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

# 遍历仓库里所有文件夹（排除 .git）
find "$REPO_ROOT" -type d -not -path '*/.git*' | sort | while read -r DIR; do
    # 跳过仓库根目录本身（可选，如果你根目录也要生成就删掉这行）
    # [[ "$DIR" == "$REPO_ROOT" ]] && continue

    # 生成【当前DIR的直接一层子文件夹】
    gen_simple() {
        find "$DIR" -maxdepth 2 -type d | sort | while read -r sub; do
            [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
            rel="${sub#$REPO_ROOT/}"
            name=$(basename "$rel")
            url=$(echo "$rel" | sed 's/ /%20/g')
            echo "- [$name](https://github.com/$REPO/tree/$BRANCH/$url)"
        done
    }

    # 生成【当前DIR下面全部层级树形】
    gen_full() {
        find "$DIR" -type d | sort | while read -r sub; do
            [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
            rel="${sub#$REPO_ROOT/}"
            # 计算缩进层级
            level=$(awk -F '/' '{print NF-1}' <<< "$rel")
            indent=""
            for ((i=0;i<level;i++)); do indent+="  "; done
            name=$(basename "$rel")
            url=$(echo "$rel" | sed 's/ /%20/g')
            echo "$indent- [$name](https://github.com/$REPO/tree/$BRANCH/$url)"
        done
    }

    # 写入这个文件夹里面的 README.md
    cat > "$DIR/README.md" <<MD
# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>📁 只显示直接下一级文件夹</summary>

$(gen_simple)

</details>

<details>
<summary>📁 完整树形（全部下层文件夹展开）</summary>

$(gen_full)

</details>
MD

    echo "✅ 已生成：$DIR/README.md"
done

echo "🎉 全部文件夹处理完毕！"

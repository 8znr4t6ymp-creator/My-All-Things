#!/bin/bash
REPO="8znr4t6ymp-creator/My-All-Things"
BRANCH="main"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

find "$REPO_ROOT" -type d -not -path '*/.git*' | sort | while read -r DIR; do
    # 临时文件，每个目录单独生成，防止串内容
    tmp1=$(mktemp)
    tmp2=$(mktemp)

    # ========== 生成【显示下一级】内容 ==========
    find "$DIR" -maxdepth 2 -type d | sort | while read -r sub; do
        [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
        rel="${sub#$REPO_ROOT/}"
        name=$(basename "$rel")
        url=$(echo "$rel" | sed 's/ /%20/g')
        echo "- [$name](https://github.com/$REPO/tree/$BRANCH/$url)" >> "$tmp1"
    done

    # ========== 生成【显示所有】完整树形 ==========
    find "$DIR" -type d | sort | while read -r sub; do
        [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
        rel="${sub#$DIR/}"
        IFS='/' read -ra seg <<< "$rel"
        depth=${#seg[@]}
        indent=""
        for ((i=0;i<depth-1;i++)); do
            indent+="  "
        done
        name="${seg[-1]}"
        full_rel="${sub#$REPO_ROOT/}"
        url=$(echo "$full_rel" | sed 's/ /%20/g')
        echo "${indent}- [$name](https://github.com/$REPO/tree/$BRANCH/$url)" >> "$tmp2"
    done

    # ========== 合并写入README ==========
    cat > "$DIR/README.md" <<MD
# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>显示下一级</summary>

$(cat "$tmp1")

</details>

<details>
<summary>显示所有</summary>

$(cat "$tmp2")

</details>
MD
    rm -f "$tmp1" "$tmp2"
    echo "✅ $DIR/README.md"
done
echo "✅ 全部生成完成，两个折叠块都保留，链接正常"

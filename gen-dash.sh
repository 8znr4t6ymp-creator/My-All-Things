#!/bin/bash
REPO="8znr4t6ymp-creator/My-All-Things"
BRANCH="main"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

# 显示下一级（直接子文件夹，带链接）
gen_simple() {
    local DIR="$1"
    find "$DIR" -maxdepth 2 -type d | sort | while read -r sub; do
        [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
        rel="${sub#$REPO_ROOT/}"
        name=$(basename "$rel")
        url=$(echo "$rel" | sed 's/ /%20/g')
        echo "- [$name](https://github.com/$REPO/tree/$BRANCH/$url)"
    done
}

# 显示所有（完整缩进树形，带链接）
gen_dash_tree() {
    local root="$1"
    find "$root" -type d | sort | while read -r dir; do
        [[ "$dir" == "$root" || "$dir" == *"/.git"* ]] && continue
        rel="${dir#$root/}"
        IFS='/' read -ra seg <<< "$rel"
        depth=${#seg[@]}
        indent=""
        for ((i=0;i<depth-1;i++)); do
            indent+="  "
        done
        name="${seg[-1]}"
        full_rel="${dir#$REPO_ROOT/}"
        url=$(echo "$full_rel" | sed 's/ /%20/g')
        echo "${indent}- [$name](https://github.com/$REPO/tree/$BRANCH/$url)"
    done
}

find "$REPO_ROOT" -type d -not -path '*/.git*' | sort | while read -r DIR; do
    simple=$(gen_simple "$DIR")
    tree=$(gen_dash_tree "$DIR")
    cat > "$DIR/README.md" <<MD
# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>显示下一级</summary>

$simple

</details>

<details>
<summary>显示所有</summary>

$tree

</details>
MD
    echo "✅ $DIR/README.md"
done
echo "✅ 生成完成，两处都带可点击链接"

#!/bin/bash
REPO="8znr4t6ymp-creator/My-All-Things"
BRANCH="main"

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

# 单层列表：直接下级，普通 - 横杠
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

# 生成 ASCII 树形 ├─ └─ │
gen_ascii_tree() {
    local DIR="$1"
    local all_subdirs
    all_subdirs=$(find "$DIR" -type d | sort)

    while read -r sub; do
        [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
        rel="${sub#$REPO_ROOT/}"
        IFS='/' read -ra parts <<< "$rel"
        depth=${#parts[@]}
        local prefix=""

        for ((i=0; i < depth - 1; i++)); do
            local parent_parts=("${parts[@]:0:i+1}")
            local parent_rel="${parent_parts[*]}"
            parent_rel="${parent_rel// /\/}"
            local parent_dir="$REPO_ROOT/$parent_rel"

            local siblings=($(find "$parent_dir" -maxdepth 1 -type d | sort))
            local last_sib="${siblings[-1]}"

            if (( i == depth - 2 )); then
                if [[ "$sub" == "$last_sib" ]]; then
                    prefix+="└─ "
                else
                    prefix+="├─ "
                fi
            else
                if [[ "$sub" == "$last_sib" ]]; then
                    prefix+="   "
                else
                    prefix+="│  "
                fi
            fi
        done

        name=$(basename "$rel")
        url=$(echo "$rel" | sed 's/ /%20/g')
        echo "${prefix}[$name](https://github.com/$REPO/tree/$BRANCH/$url)"
    done <<< "$all_subdirs"
}

# 遍历仓库所有文件夹，逐个生成README
find "$REPO_ROOT" -type d -not -path '*/.git*' | sort | while read -r DIR; do
    simple=$(gen_simple "$DIR")
    tree=$(gen_ascii_tree "$DIR")

    cat > "$DIR/README.md" <<MD
# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>📁 只显示直接下一级文件夹</summary>

$simple

</details>

<details>
<summary>📁 完整树形（ASCII ├─ └─）</summary>

$tree

</details>
MD
    echo "✅ 生成：$DIR/README.md"
done

echo "🎉 全部文件夹ASCII树形README生成完毕！"

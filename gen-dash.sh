#!/bin/bash
REPO="8znr4t6ymp-creator/My-All-Things"
BRANCH="main"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

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

TMP_SIMPLE=$(mktemp)
TMP_TREE=$(mktemp)

find "$REPO_ROOT" -type d -not -path '*/.git*' | sort | while read -r DIR; do
    gen_simple "$DIR" > "$TMP_SIMPLE"
    gen_dash_tree "$DIR" > "$TMP_TREE"

cat > "$DIR/README.md" <<MD
# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>显示下一级</summary>

$(cat "$TMP_SIMPLE")

</details>

<details>
<summary>显示所有</summary>

$(cat "$TMP_TREE")

</details>
MD
    echo "✅ $DIR/README.md"
done

rm -f "$TMP_SIMPLE" "$TMP_TREE"
echo "✅ 全部生成完成"

#!/bin/bash
REPO="8znr4t6ymp-creator/My-All-Things"
BRANCH="main"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

find "$REPO_ROOT" -type d -not -path '*/.git*' | sort | while read -r DIR; do
    # 写入头部
    cat > "$DIR/README.md" <<'HEAD'
# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>显示下一级</summary>

HEAD

    # 写入【显示下一级】
    find "$DIR" -maxdepth 2 -type d | sort | while read -r sub; do
        [[ "$sub" == "$DIR" || "$sub" == *"/.git"* ]] && continue
        rel="${sub#$REPO_ROOT/}"
        name=$(basename "$rel")
        url=$(echo "$rel" | sed 's/ /%20/g')
        echo "- [$name](https://github.com/$REPO/tree/$BRANCH/$url)" >> "$DIR/README.md"
    done

    # 关闭第一个details，开启第二个
    cat >> "$DIR/README.md" <<'MID'

</details>

<details>
<summary>显示所有</summary>

MID

    # 写入【显示所有】树形
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
        echo "${indent}- [$name](https://github.com/$REPO/tree/$BRANCH/$url)" >> "$DIR/README.md"
    done

    # 闭合第二个details
    echo -e "\n</details>" >> "$DIR/README.md"
    echo "✅ $DIR/README.md"
done
echo "✅ 生成结束"

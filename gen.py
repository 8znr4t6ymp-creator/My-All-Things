import os

REPO = "8znr4t6ymp-creator/My-All-Things"
BRANCH = "main"
ROOT = os.path.abspath(".")

def get_subdirs(dir_path, maxdepth=None):
    res = []
    for root, dirs, files in os.walk(dir_path):
        if ".git" in dirs:
            dirs.remove(".git")
        level = root[len(dir_path):].count(os.sep)
        if maxdepth is not None and level >= maxdepth:
            dirs[:] = []
        for d in dirs:
            full = os.path.join(root, d)
            res.append(full)
    return sorted(res)

for current_dir, _, _ in os.walk(ROOT):
    if ".git" in current_dir:
        continue
    level1 = get_subdirs(current_dir, maxdepth=1)
    block1 = []
    for p in level1:
        rel = os.path.relpath(p, ROOT)
        rel = rel.replace(" ", "%20")
        name = os.path.basename(p)
        block1.append(f"- [{name}](https://github.com/{REPO}/tree/{BRANCH}/{rel})")

    all_dirs = get_subdirs(current_dir)
    block2 = []
    for p in all_dirs:
        rel_current = os.path.relpath(p, current_dir)
        parts = rel_current.split(os.sep)
        depth = len(parts)
        indent = "  " * (depth - 1)
        rel = os.path.relpath(p, ROOT)
        rel = rel.replace(" ", "%20")
        name = os.path.basename(p)
        block2.append(f"{indent}- [{name}](https://github.com/{REPO}/tree/{BRANCH}/{rel})")

    md = """# Contents

在这里写这个文件夹的介绍、分类、备注。

<details>
<summary>显示下一级</summary>

"""
    md += "\n".join(block1)
    md += """

</details>

<details>
<summary>显示所有</summary>

"""
    md += "\n".join(block2)
    md += """

</details>
"""
    readme_path = os.path.join(current_dir, "README.md")
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(md)
    print(f"✅ {readme_path}")

print("✅ 全部生成完成")

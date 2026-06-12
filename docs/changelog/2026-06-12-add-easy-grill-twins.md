# 2026-06-12 Add Easy-Grill Twins

## What Changed

- 新增 `skills/easy-grill/`(全英文)+ `skills/easy-grill-zh/`(全中文)跨语言孪生 skill;同名文件已安装在本地 `~/.claude/skills/`,与仓库逐字一致。
- README 索引「写作 / 通用工具」加两行;third-party notices 补 `grill-me` 上游署名。

## 设计

- **基底只做加法**:Matt Pocock 的 `grill-me` 提示词在英文版逐字保留、在中文版忠实翻译,一字不删不改;两个提升点全部以追加小节实现。
- **加法一(怎么写)**:注入可读性尺子 — 写作标准底盘(结论先行 / 一句一意 / 不自造词 / 断言与证据相称 / 不留脚手架)+ 白话分叉(十二岁读者 / 术语先解释 / 比方讲透 / 短铺垫)。中文版用 bullet 体中文母版,英文版用段落体英文母带,与 Sedna `prompt-registry` 的两把尺子逐字同源。
- **加法二(怎么问)**:探针问题等价变换 — 需要技术背景才能答的问题,先变换成用户凭直觉可答的探针;保真判据是"探针的每一种可能回答都能推出原问题的一个确定答案";找不到保真探针时退路是先白话讲清概念再问原问题;答完复述推出的决定 + 它换来什么放弃什么,给用户当场纠正的机会。
- **决策留痕**:十二岁条目曾试过下限式措辞("即使是孩子也能读懂"),辩论后定稿命令式("把目标读者设成十二岁孩子")。理由:prompt 是生成端控制信号,命令式给模型可代入的写作姿态;属性式措辞是验收端标准的正确形式,放在生成端会让化简力度变松。与 `knowledge-assets/prompt-craft.md` "给模型写标准 = 下命令"一致。
- **孪生纪律**:两文件头部互指注释,改一边必须同步另一边(同中英尺子 BY HAND sync 的约定)。

## Source

- 基底上游:https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md (MIT,署名见 [`third-party-notices.md`](../third-party-notices.md))

## 关联

- 方法论:[`knowledge-assets/prompt-craft.md`](../../knowledge-assets/prompt-craft.md)(命令式写标准)
- 近亲 skill:[`skills/grill-with-docs/`](../../skills/grill-with-docs/)(同为 grill 家族,主打对齐项目术语;easy-grill 主打降低理解门槛)

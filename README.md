# 小红书图文草稿填写

把你已经定稿的标题、正文和自有授权图片填写到指定小红书账号的图文草稿中，并给你一份清晰的“已填字段、来源、缺项、停在发布前”回执。它不写文案、不采集内容，也绝不替你点击发布。

![小红书图文草稿填写推广图](assets/promo.png)

## 输入与结果

输入为：明确的 `browserId`、已确认归属的账号、授权图片、定稿标题和正文；话题或地点等字段可选。单次处理一篇短图文；表格资料最多 100 行，超出需分批。

结果为：网页可见的已填字段清单、每条文字和图片的真实来源、缺项/阻断原因，以及“停在发布前”的状态。账号不明确、素材缺失、验证码/风控或页面变化会立刻停止，绝不绕过。

## 安装

```bash
npx skills add xxjrq/xiaohongshu-draft-fill-free
```

这是浏览器 Skill，需要先安装 [Easy WebBridge（GitHub）](https://github.com/xxjrq/easy-webbridge)，GitHub 不可用时使用 [Gitee 备用地址](https://gitee.com/xxjrq/easy-webbridge)。按其安装说明连接浏览器；运行时只使用你明确给出的 `browserId`，一项任务一个独立 session 标签组，不会广播给其他账号。

## 使用

```text
使用 browserId <我指定的环境>，把我授权的图片、定稿标题和正文填写成小红书图文草稿。先确认账号；完成后停在发布前，列出已填字段、来源和缺项，不要发布。
```

执行时仅根据网页可见内容操作，页面变化后会刷新快照引用。遇登录、验证码、安全验证或风控，请由账号持有人处理后再继续。

## 边界

- 默认只读；只有明确授权“填写草稿”才修改表单。
- 不点击发布、发送、提交或最终确认按钮。
- 不接管现有标签页；只关闭本任务自己创建且核对过所有权的 session。
- `fixtures/` 是离线资料模拟，用于自测，不代表在线采集或真实运行记录。

## 本地自测

```bash
bash scripts/self-test.sh
```

参考来源仅用于理解平台适配场景：[OpenCLI](https://github.com/jackwener/OpenCLI)（未复制其代码或原文实现；本仓库为原创工作流说明）。

许可证：[MIT](LICENSE)。英文说明见 [README.en.md](README.en.md)。

## 可选字段与上传

话题、地点未提供时，仍可填授权图片、定稿标题和正文，但回执逐项写明可选字段未填。首次导航必须带 navigate、用户指定 browserId、确认页面 URL 和本任务 session；图片上传的 command upload 及 tabId/selector/files 参数见 [SKILL.md](SKILL.md)。需要核对顶层唯一文件输入框及可见缩略图，不能把上传调用本身当作已填证据。所有离线样例的 expected_receipt 是预期合同，不代表已执行线上填写。

---
name: xiaohongshu-draft-fill-free
description: 在用户指定且已授权的 Easy WebBridge 浏览器环境中，把本地授权图片、定稿标题与正文填写到小红书图文草稿表单；交付已填字段、来源与缺项清单，并始终停在发布前。适用于已有成稿的单篇图文；账号不明确、素材缺失、登录验证、风控或页面结构变化时立即停止，不采集内容、不生成文案也不点击发布。
---

# 小红书图文草稿填写

将用户已定稿的图文资料准确填写进其本人账号的草稿页面，便于用户在发布前人工复核。

## 输入

- 明确指定的 `browserId`，以及对应账号可操作的确认。
- 用户自有或已获授权的本地图片路径、定稿标题和正文；可选话题/地点等字段。
- 单次处理一篇已定稿图文；表格资料最多 100 行，超出时先要求分批。

## 结果

返回可见的草稿状态回执：已填字段、每张图片和文字的真实来源、未填/无法填的字段，以及“停在发布前”的确认。绝不把离线样例当作线上读取结果。

## 前置依赖：Easy WebBridge

这是浏览器 Skill。安装 Easy WebBridge：GitHub 主地址 <https://github.com/xxjrq/easy-webbridge>；Gitee 备用地址 <https://gitee.com/xxjrq/easy-webbridge>。按其仓库说明加载扩展并启动本地 Bridge。仅使用用户明确给出的 `browserId`，不得广播到所有浏览器或账号。

## 执行流程

1. 先将已安装的 Easy WebBridge CLI 设为同一个可解析路径：`EASY_WEBBRIDGE_CLI="/path/to/easy-webbridge/cli/easy-webbridge.mjs"`，确认该文件存在后运行 `node "$EASY_WEBBRIDGE_CLI" --help`。后续所有 CLI 调用都沿用 `node "$EASY_WEBBRIDGE_CLI" ...`；列出浏览器后，若未给出 `browserId` 或账号归属不明确，停止并说明缺项。
2. 建立本任务独有的 session（`xiaohongshu-draft-fill-free-<run-id>`）与标签组；只管理此组，绝不接管或关闭用户已有页面。将 `BROWSER_ID` 设为用户本次明确指定的环境，将 `DRAFT_URL` 设为本次已确认的草稿页面地址，`TASK_SESSION` 为上述独立名称。首个页面的完整命令为：`node "$EASY_WEBBRIDGE_CLI" navigate "$BROWSER_ID" "$DRAFT_URL" --new-tab --session "$TASK_SESSION" --group-title "小红书草稿填写"`。保存此次返回的 `tabId`；后续始终复用该 session 内页面，不省略 browserId，不把用户原有标签登记为本任务资产。
3. 首次和每次页面变化后使用 `node "$EASY_WEBBRIDGE_CLI" snapshot <browserId> <tabId> --text-mode page`，刷新元素引用；只依据网页可见内容操作。页面结构无法确认时停止。
4. 核对素材：标题、正文与所有图片必须存在并已获授权。填写标题、正文、图片和用户明确提供的可选字段；记录每个字段的原始来源。图片使用下方明确的 `command <browserId> upload <args-json>`，不能用点击按钮冒充上传成功。话题、地点是可选项；未提供时不阻止必需字段填写，但必须逐项写入未填/缺项回执，不能说没有缺项。不能补写、猜测或把样例冒充真实来源。
5. 遇到登录、验证码、风控、账号不明、素材缺失、上传失败或页面变化，立即停止；不绕过验证。
6. 完成填写后，再次用 `--text-mode page` 快照确认可见字段，**不点击发布、发送、提交或任何最终确认按钮**。输出回执；仅关闭本次创建且已核对所有权的 session。

## 图片上传命令与参数

运行前先阅读已安装 Easy WebBridge 的 `skills/easy-webbridge/references/api.md` 中 upload、fill、snapshot 与 close_session 参数。这里的 `123`、文件路径和 selector 都是文档占位：`tabId` 必须替换为本次独立导航返回的数字，selector 必须来自当前页核对过的唯一文件输入框，files 只放本次已授权且存在的绝对路径。

```bash
node "$EASY_WEBBRIDGE_CLI" command "$BROWSER_ID" upload '{"tabId":123,"selector":"input[type=file]","files":["/path/to/authorized/image-01.jpg","/path/to/authorized/image-02.jpg"]}'
```

`input[type=file]` 仅为参数形状示例，不能未核对就套用。若页面有多个文件输入框，需要依据实际 DOM 选定唯一目标；当前 upload 只支持顶层页面，文件框在 iframe 内时说明阻塞，不能宣称已上传。收到上传响应后刷新 snapshot，核对可见缩略图与数量；没有可见证据时回执写“无法确认”，不能写已填。

标题与正文使用当前 snapshot 的新 ref。用户文本不得插入 shell 双引号参数，也不得通过 `eval`、命令替换或拼接 shell 命令传递。用 Python 从标准输入读取 JSON，再以参数数组启动 CLI；用户文本只作为 JSON 数据，不经 shell 展开：

```bash
python3 -c 'import json,subprocess,sys; cli,browser_id,ref,tab_id=sys.argv[1:]; payload=json.load(sys.stdin); subprocess.run(["node",cli,"fill",browser_id,ref,payload["text"],tab_id],check=True)' \
  "$EASY_WEBBRIDGE_CLI" "$BROWSER_ID" "$CURRENT_REF" "$TAB_ID" <<'JSON'
{"text":"这里放安全 JSON 序列化器产生的定稿正文"}
JSON
```

Python 代码通过 `-c` 参数提供，标准输入只承载 JSON，不再被 Python heredoc 占用。上例是结构示意，运行时 JSON 必须由序列化器生成；即使正文含中文、引号、反引号或 `$()`，它们也只是 JSON 字符串，不会经过 shell 解释。`fixtures/mock-fill-cli.mjs` 与自测会离线执行同一调用形状；mock 回执明确标记模拟状态，不证明线上已填写。需要使用 snapshot 返回的 frameId 时，将其作为独立参数传 `--frame-id <frameId>`。清理只用 `node "$EASY_WEBBRIDGE_CLI" command "$BROWSER_ID" close_session '{"session":"<本次TASK_SESSION>"}'`，先确认归属再关闭。

## 安全边界

- 默认只读；只有用户明确授权“填写草稿”才改变表单内容。
- 不生成文案、不抓取在线素材、不跨账号操作，也不处理未经授权的媒体。
- 发布按钮即使可见也不得点击；最终发布完全由用户完成。

## 回执格式

```text
状态：已填写，停在发布前
已填字段：图片（2）、标题、正文
来源：图片=/用户提供的文件；标题/正文=/用户定稿文本
未填/缺项：话题未提供，未填写（可选）；地点未提供，未填写（可选）
阻断：无
```

以上“已填写”只用于线上确有可见字段证据的回执。fixtures 中的上传响应、缩略图和字段回读均为离线模拟证据，仅描述预期合同；自检不执行或证明浏览器填写，离线回执状态必须是“模拟已填写，未执行线上填写”，不得表述成线上已填写。

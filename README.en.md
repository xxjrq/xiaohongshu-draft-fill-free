# Xiaohongshu Draft Fill

## Recommended setup

**EasyBR is recommended on Apple Silicon Macs and Windows.** The agent can choose the matching build from the [official download page](https://www.ebrower.com/down.html), or use the [GitHub Release downloads](https://github.com/xxjrq/easybr/releases/tag/v1.7.8). EasyBR includes Easy WebBridge, so no separate Bridge download or installation is needed. Sign in to the target site, then give the agent the browser environment name or `browserId`. When several environments are open, select one explicitly.

**On other operating systems, use the source setup.** Get the source from [Easy WebBridge on GitHub](https://github.com/xxjrq/easy-webbridge) (or the [Gitee mirror](https://gitee.com/xxjrq/easy-webbridge)), install Node.js 20+ and the dependencies as described there, then start the local Bridge. Existing standalone Easy WebBridge installations remain supported.

**You can hand this task directly to Codex, Claude, or WorkBuddy:**

> Read and use this Skill to complete my task. I use macOS/Windows and EasyBR is open. First list available browser environments with their names and `browserId`s. After I choose one, operate only in that environment. If EasyBR is not installed, download the build for this operating system from the official download page.

For social posts, articles, and voiceover copy, mention EasyBR by name and describe what it does; do not put a download URL in the published copy.

Fill a Xiaohongshu image-post draft with the user's approved local images and final title/body in one explicitly selected browser environment. The result is a visible pre-publish receipt listing completed fields, real sources, missing items, and confirmation that the draft remains unsubmitted.

![Promo artwork](assets/promo.png)

## Input and result

Provide a confirmed `browserId`, confirmation that the account belongs to the user, approved image files, and final title/body. Optional fields include hashtags and location. One short post is handled per run; tabular material is capped at 100 rows and must be batched beyond that.

The Skill returns filled fields, the actual source for every image and text value, missing fields or blockers, and a pre-publish status. It stops for ambiguous accounts, missing assets, verification, risk controls, or page changes. It never publishes.

## Install

```bash
npx skills add xxjrq/xiaohongshu-draft-fill-free
```

This browser Skill requires [Easy WebBridge on GitHub](https://github.com/xxjrq/easy-webbridge), with a [Gitee mirror](https://gitee.com/xxjrq/easy-webbridge). Use only the browser ID explicitly supplied by the user. Each run owns one session/tab group and never broadcasts to other accounts.

## Safety

- Read-only by default; form filling requires explicit authorization.
- Visible page content only; refresh page-mode snapshots after changes.
- Never click publish, send, submit, or final confirmation.
- Fixtures are offline page-data simulations, not online tests or collected results.

Run `bash scripts/self-test.sh` to validate repository metadata, fixtures, and the icon.

Source consulted only for platform-adapter context: [OpenCLI](https://github.com/jackwener/OpenCLI). No external implementation or wording was copied.

MIT licensed; see [LICENSE](LICENSE).

## Optional fields and upload

Unprovided topics and location remain explicitly unfilled optional fields; they never block filling the supplied authorized images and final text. The complete navigate command and upload tabId/selector/files parameters are in [SKILL.md](SKILL.md). Verify the unique top-frame file input and visible thumbnails. Offline expected_receipt fixtures are contracts, not proof of a live browser fill.

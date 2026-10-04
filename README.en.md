# Xiaohongshu Draft Fill

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

#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
for file in SKILL.md manifest.yaml agents/openai.yaml README.md README.en.md LICENSE icon-512.png fixtures/success-input.json fixtures/failure-input.json fixtures/mock-fill-cli.mjs; do
  test -f "$file" || { echo "missing: $file"; exit 1; }
done
grep -q '^name: xiaohongshu-draft-fill-free$' SKILL.md
grep -q '^name: xiaohongshu-draft-fill-free$' manifest.yaml
grep -q '^slug: xiaohongshu-draft-fill-free$' manifest.yaml
grep -q '^icon: icon-512.png$' manifest.yaml
grep -q 'allow_implicit_invocation: false' agents/openai.yaml
grep -q 'text-mode page' SKILL.md
grep -q '不点击发布' SKILL.md
grep -q '/path/to/easy-webbridge/cli/easy-webbridge.mjs' SKILL.md
! grep -q 'node cli/easy-webbridge.mjs' SKILL.md
python3 - <<'PY'
import json, struct, re
from pathlib import Path
skill = Path('SKILL.md').read_text()
assert 'navigate "$BROWSER_ID" "$DRAFT_URL" --new-tab --session "$TASK_SESSION"' in skill, 'navigation must include verb, browser, URL and own session'
assert 'command "$BROWSER_ID" upload' in skill, 'upload command missing'
upload_json = re.search(r'upload \'(\{[^\n]+\})\'', skill)
assert upload_json, 'upload args must include a parseable JSON example'
upload = json.loads(upload_json.group(1))
assert isinstance(upload['tabId'], int) and upload['selector'] and all(Path(x).is_absolute() for x in upload['files'])
assert '当前 upload 只支持顶层页面' in skill
for file in ('manifest.yaml', 'agents/openai.yaml'):
    metadata = Path(file).read_text()
    for field in ('display_name', 'short_description', 'default_prompt', 'icon_small', 'icon_large'):
        found = re.search(r'^  ' + field + r': "([^"\n]+)"$', metadata, re.M)
        assert found, f'interface string must be quoted: {field}'
        value = found.group(1)
        if field == 'default_prompt':
            assert '$xiaohongshu-draft-fill-free' in value
        elif field == 'short_description':
            assert 25 <= len(value) <= 64
        elif field.startswith('icon_'):
            target = Path(value).resolve()
            assert target.is_relative_to(Path.cwd()) and target.is_file()
for path in ('fixtures/success-input.json', 'fixtures/failure-input.json'):
    with open(path, encoding='utf-8') as f: json.load(f)
with open('fixtures/success-input.json', encoding='utf-8') as f:
    success = json.load(f)
for image in success['images']:
    with open(image, 'rb') as f:
        assert f.read(2) == b'\xff\xd8', f'{image} is not a JPEG fixture'
sources = success['expected_receipt']['sources']
assert len(sources['images']) == len(success['images'])
assert sources['title']['source'] and sources['body']['source']
evidence = success['offline_page_evidence']
assert evidence['upload_response']['count'] == len(success['images'])
assert len(evidence['visible_thumbnails']) == len(success['images']) and all(x['visible'] for x in evidence['visible_thumbnails'])
assert evidence['visible_field_readback'] == {'title': success['title'], 'body': success['body']}
assert evidence['publish_clicked'] is False
for branch in ('success', 'failure'):
    fixture = json.loads(Path(f'fixtures/{branch}-input.json').read_text())
    expected = fixture['expected_receipt']
    assert expected['receipt_verified_online'] is False and '离线' in expected['evaluation_mode']
    for key, label in [('topics', '话题'), ('location', '地点')]:
        if not fixture.get(key):
            assert any(label+'未提供' in field for field in expected['missing_fields']), f'unprovided optional {key} must be reported'
            assert label not in expected['filled_fields'], f'unprovided optional {key} cannot be filled'
assert success['expected_receipt']['filled_fields'] == ['图片', '标题', '正文']
assert success['expected_receipt']['status'].startswith('模拟已填写')
failure = json.loads(Path('fixtures/failure-input.json').read_text())
assert not failure['expected_receipt']['filled_fields']
assert failure['account_confirmation'] == '未确认账号归属' and '登录验证' not in failure
assert '访问页面前停止' in failure['expected_receipt']['blockers'][0]
with open('icon-512.png', 'rb') as f:
    header = f.read(24)
assert header[:8] == b'\x89PNG\r\n\x1a\n', 'icon is not PNG'
w, h = struct.unpack('>II', header[16:24])
assert (w, h) == (512, 512), f'icon dimensions are {w}x{h}'
print('self-test passed: executable CLI argument shapes, explicit optional omissions, offline receipt contracts, sources, and 512px icon')
print('NOTE: no browser command was executed; expected receipts do not claim live filling.')
PY
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
export XHS_MOCK_TRACE="$tmpdir/trace.jsonl"
marker=/tmp/xhs-draft-fill-free-shell-expanded
rm -f "$marker"
python3 -c 'import json,subprocess,sys; cli,browser,ref,tab=sys.argv[1:]; payload=json.load(sys.stdin); subprocess.run(["node",cli,"fill",browser,ref,payload["text"],tab],check=True)' \
  "$PWD/fixtures/mock-fill-cli.mjs" mock-browser @e1 17 <<'JSON' > "$tmpdir/result.json"
{"text":"中文“引号” '单引号' `反引号` $(touch /tmp/xhs-draft-fill-free-shell-expanded)"}
JSON
python3 - "$tmpdir/trace.jsonl" "$marker" <<'PY'
import json,sys
record=json.loads(open(sys.argv[1],encoding='utf-8').read())
assert record['mock_only'] is True
assert record['argv'][0:3] == ['fill','mock-browser','@e1']
assert record['argv'][3] == "中文“引号” '单引号' `反引号` $(touch /tmp/xhs-draft-fill-free-shell-expanded)"
import os
assert not os.path.exists(sys.argv[2]), 'shell evaluated content supplied as JSON data'
print('PASS: JSON stdin reaches offline CLI mock unchanged; shell metacharacters were not evaluated; receipt is mock-only.')
PY

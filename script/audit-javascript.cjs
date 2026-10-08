// 修正版が未公開のビルド依存だけを期限付きで区別し、新しい検出は失敗させる。
const { spawnSync } = require('node:child_process');
const { readFileSync } = require('node:fs');
const exceptions = JSON.parse(readFileSync(new URL('../config/javascript-audit-exceptions.json', `file://${__filename}`), 'utf8'));
const result = spawnSync('yarn', ['npm', 'audit', '--all', '--recursive', '--json', '--no-deprecations'], { encoding: 'utf8' });
if (result.error || ![0, 1].includes(result.status)) {
  console.error(result.error || result.stderr);
  process.exit(1);
}
let failed = false;
let count = 0;
for (const line of result.stdout.split('\n').filter(Boolean)) {
  const item = JSON.parse(line);
  const advisory = item.children;
  if (!advisory?.URL) {
    console.error(line);
    failed = true;
    continue;
  }
  count++;
  const exception = exceptions.find(entry => entry.package === item.value && entry.url === advisory.URL &&
    new Date(`${entry.expires}T00:00:00Z`) > new Date());
  if (exception) {
    console.warn(`期限付き例外 (${exception.expires}): ${item.value} ${advisory.URL}\n${exception.reason}`);
  } else {
    console.error(line);
    failed = true;
  }
}
if (result.status === 1 && count === 0) failed = true;
console.log(`監査完了: ${count}件の該当。未承認の検出: ${failed ? 'あり' : 'なし'}`);
process.exit(failed ? 1 : 0);

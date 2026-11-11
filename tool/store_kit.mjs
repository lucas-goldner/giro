#!/usr/bin/env node
// App Store screenshots for every language: shoots the web preview at the
// iPhone 6.9" size (1290 × 2796) in each supported locale, then frames each
// shot under a localized headline (docs/store/headlines.json) in the Sonic
// HUD style. Output: build/store_kit/shots/<lang>/iphone/NN_<name>.png and
// the raw shots in build/store_kit/raw/.
//
//   flutter build web -t lib/main_web.dart
//   node tool/store_kit.mjs [--langs en,ja] [--skip-shoot]
//
// CJK headlines need Noto Sans JP/KR/SC: `npm pack @fontsource/noto-sans-jp
// @fontsource/noto-sans-kr @fontsource/noto-sans-sc` into build/store_kit/
// fontsrc/ (the tool unpacks them; see README).
import { createServer } from 'node:http';
import { createReadStream, cpSync, existsSync, mkdirSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, extname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const { chromium } = createRequire(import.meta.url)('playwright');
const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const flag = (name) => { const i = args.indexOf(name); return i >= 0 ? args[i + 1] : undefined; };
const out = join(projectRoot, 'build/store_kit');
const rawDir = join(out, 'raw');
const shotsDir = join(out, 'shots');
const fontsDir = join(out, 'fonts');
const headlines = JSON.parse(readFileSync(join(projectRoot, 'docs/store/headlines.json'), 'utf8'));
const langs = (flag('--langs') ?? 'en,ja,zh,ko,de,fr,es,it,pt').split(',');
const names = headlines.shots;
const W = 1290, H = 2796, SCALE = 3;

const mime = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json',
  '.png': 'image/png', '.wasm': 'application/wasm', '.otf': 'font/otf', '.ttf': 'font/ttf', '.woff2': 'font/woff2', '.woff': 'font/woff' };
function serve(dir) {
  return new Promise((done) => {
    const server = createServer((req, res) => {
      const path = decodeURIComponent(new URL(req.url, 'http://x').pathname);
      let file = join(dir, path === '/' ? 'index.html' : path);
      if (!existsSync(file) || statSync(file).isDirectory()) file = join(dir, 'index.html');
      res.setHeader('Content-Type', mime[extname(file)] ?? 'application/octet-stream');
      res.setHeader('Cache-Control', 'no-store');
      createReadStream(file).pipe(res);
    });
    server.listen(0, '127.0.0.1', () => done(server));
  });
}

function arb(lang) {
  return JSON.parse(readFileSync(join(projectRoot, `lib/l10n/app_${lang}.arb`), 'utf8'));
}

async function tap(page, label) {
  const button = page.getByRole('button', { name: label }).first();
  await button.waitFor({ state: 'attached', timeout: 20000 });
  try { await button.click({ timeout: 4000 }); } catch {
    if (await button.count()) await button.dispatchEvent('click', {}, { timeout: 3000 }).catch(() => {});
  }
  await page.waitForTimeout(900);
}

async function shoot(browser, url, lang) {
  const t = arb(lang);
  const backLabel = t.back.replace(/^◀\s*/, '');
  const dir = join(rawDir, lang);
  mkdirSync(dir, { recursive: true });
  const page = await browser.newPage({ viewport: { width: W / SCALE, height: H / SCALE }, deviceScaleFactor: SCALE, hasTouch: true });
  page.on('pageerror', (e) => console.error('page error:', e.message));
  const snap = async (name) => {
    await page.waitForTimeout(2500);
    const file = join(dir, `${name}.png`);
    await page.screenshot({ path: file });
    console.log(`  raw ${lang}/${name}`);
  };
  try {
    await page.goto(`${url}?lang=${lang}`, { waitUntil: 'load' });
    await page.getByRole('button', { name: t.stagesCaption }).first().waitFor({ state: 'attached', timeout: 60000 });
    await page.waitForTimeout(1500);
    // Fill Tokyo so the map reads as a city uncovered, not three walks.
    await tap(page, t.optionsSemantics);
    await tap(page, t.fillTokyo);
    await tap(page, backLabel);
    await page.waitForTimeout(5000);
    await page.mouse.move(W / SCALE / 2, 300);
    for (let i = 0; i < 7; i++) { await page.mouse.wheel(0, 400); await page.waitForTimeout(250); }
    await page.waitForTimeout(3000);
    await snap('city');
    await tap(page, t.stagesCaption);
    await snap('stages');
    await tap(page, /km/);
    await snap('clear');
    await tap(page, backLabel);
    await tap(page, backLabel);
    await tap(page, t.spotsSemantics);
    await snap('spots');
    await tap(page, backLabel);
    await tap(page, t.goSemantics);
    await tap(page, t.startRecording);
    await page.waitForTimeout(11500);
    await snap('record');
    await tap(page, backLabel);
    await tap(page, t.optionsSemantics);
    await tap(page, t.downloadMapArea);
    await snap('offline');
  } finally {
    await page.close();
  }
}

function prepareFonts() {
  mkdirSync(fontsDir, { recursive: true });
  cpSync(join(projectRoot, 'assets/fonts'), join(fontsDir, 'barlow'), { recursive: true });
  const src = flag('--fonts') ?? join(out, 'fontsrc');
  if (!existsSync(src)) {
    console.warn(`no CJK fonts in ${src}; Japanese, Chinese and Korean headlines use system fonts`);
    return '';
  }
  let css = '';
  for (const pkg of readdirSync(src)) {
    const base = join(src, pkg, 'package');
    if (!existsSync(join(base, '900.css'))) continue;
    cpSync(join(base, 'files'), join(fontsDir, pkg, 'files'), { recursive: true });
    for (const weight of ['700', '900']) {
      css += readFileSync(join(base, `${weight}.css`), 'utf8').replaceAll('./files/', `fonts/${pkg}/files/`) + '\n';
    }
  }
  return css;
}

function frameHtml(lang, name, fontCss) {
  const h = headlines[lang][name];
  const cjk = ['ja', 'zh', 'ko'].includes(lang);
  const family = { ja: '"Noto Sans JP"', zh: '"Noto Sans SC"', ko: '"Noto Sans KR"' }[lang] ?? '"BarlowCondensed"';
  const lines = h.lines.map((l, i) => i === h.lines.length - 1
    ? `<span class="box">${esc(l)}</span>` : `<span class="line">${esc(l)}</span>`).join('');
  return `<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{font-family:BarlowCondensed;src:url(fonts/barlow/BarlowCondensed-BlackItalic.ttf);font-weight:900;font-style:italic}
@font-face{font-family:BarlowCondensed;src:url(fonts/barlow/BarlowCondensed-Bold.ttf);font-weight:700}
${fontCss}
html,body{margin:0;width:${W}px;height:${H}px;overflow:hidden}
body{background:#0A1D58;background-image:repeating-linear-gradient(-32deg,rgba(27,91,255,.22) 0 26px,transparent 26px 56px);font-family:${family},"BarlowCondensed",sans-serif;color:#fff}
.stripe{position:absolute;left:-40px;right:-40px;top:${cjk ? 760 : 720}px;height:16px;background:#1B5BFF;transform:rotate(-2.5deg)}
.head{position:absolute;left:0;right:0;top:${cjk ? 110 : 96}px;text-align:center;padding:0 60px}
.line{display:block;font-weight:900;font-style:${cjk ? 'normal' : 'italic'};font-size:${cjk ? 150 : 210}px;line-height:${cjk ? 1.12 : .92};letter-spacing:${cjk ? '-0.01em' : '0'};text-shadow:0 10px 0 #1B5BFF,0 14px 0 #071544}
.box{display:inline-block;margin-top:${cjk ? 18 : 10}px;font-weight:900;font-style:${cjk ? 'normal' : 'italic'};font-size:${cjk ? 150 : 210}px;line-height:${cjk ? 1.18 : 1};padding:${cjk ? '8px 44px 14px' : '0 48px 10px'};background:#FFC400;color:#0A1D58;border:10px solid #071544;box-shadow:16px 16px 0 #071544;transform:skewX(-8deg)}
.box{max-width:1100px}
.sub{position:absolute;left:0;right:0;top:${cjk ? 830 : 790}px;text-align:center;padding:0 110px;font-family:${cjk ? family : '-apple-system,"Segoe UI","Helvetica Neue",Arial'},sans-serif;font-weight:700;font-size:${cjk ? 46 : 48}px;line-height:1.3;color:#5FC8FF}
.phone{position:absolute;left:50%;top:${cjk ? 1010 : 970}px;transform:translateX(-50%);width:1080px;height:2340px;border-radius:120px;background:#071544;border:12px solid #FFC400;box-shadow:0 40px 0 #061240,0 60px 120px rgba(0,0,0,.45);overflow:hidden}
.phone img{position:absolute;left:0;top:0;width:1080px;height:2340px;object-fit:cover}
</style></head><body>
<div class="head">${lines}</div><div class="stripe"></div>
<div class="sub">${esc(h.sub)}</div>
<div class="phone"><img src="raw/${lang}/${name}.png"></div>
</body></html>`;
}
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');

async function compose(browser, url, fontCss) {
  const page = await browser.newPage({ viewport: { width: W, height: H }, deviceScaleFactor: 1 });
  try {
    for (const lang of langs) {
      const dir = join(shotsDir, lang, 'iphone');
      mkdirSync(dir, { recursive: true });
      for (const [i, name] of names.entries()) {
        const html = frameHtml(lang, name, fontCss);
        writeFileSync(join(out, '_frame.html'), html);
        await page.goto(`${url}_frame.html?${Date.now()}`, { waitUntil: 'load' });
        await page.evaluate(() => document.fonts.ready);
        await page.waitForTimeout(400);
        const file = join(dir, `${String(i + 1).padStart(2, '0')}_${name}.png`);
        await page.screenshot({ path: file, clip: { x: 0, y: 0, width: W, height: H } });
        console.log(`framed ${lang}/iphone/${String(i + 1).padStart(2, '0')}_${name}.png`);
      }
    }
  } finally {
    await page.close();
  }
}

async function main() {
  mkdirSync(out, { recursive: true });
  const webDir = join(projectRoot, 'build/web');
  if (!existsSync(join(webDir, 'index.html'))) throw new Error('Run: flutter build web -t lib/main_web.dart');
  const proxy = process.env.HTTPS_PROXY || process.env.https_proxy;
  const browser = await chromium.launch(proxy ? { proxy: { server: proxy, bypass: 'localhost,127.0.0.1' } } : {});
  const web = await serve(webDir);
  const kit = await serve(out);
  try {
    if (!args.includes('--skip-shoot')) {
      const url = `http://127.0.0.1:${web.address().port}/`;
      for (const lang of langs) {
        console.log(`shooting ${lang}`);
        await shoot(browser, url, lang);
      }
    }
    const fontCss = prepareFonts();
    await compose(browser, `http://127.0.0.1:${kit.address().port}/`, fontCss);
  } finally {
    await browser.close();
    web.close();
    kit.close();
  }
}

main().catch((error) => { console.error(error); process.exit(1); });

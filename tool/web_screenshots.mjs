#!/usr/bin/env node
// Drives the web preview (lib/main_web.dart) through its main screens with
// the Playwright Chromium that ships in the Claude Code container and saves
// screenshots to build/web_screenshots/.
//
//   flutter build web -t lib/main_web.dart
//   node tool/web_screenshots.mjs            # serves build/web itself
//   node tool/web_screenshots.mjs --url http://localhost:8080/
//
// Options: --url <url>  use an already running server (e.g. `flutter run -d
//                       web-server -t lib/main_web.dart --web-port 8080`)
//          --out <dir>  screenshot directory (default build/web_screenshots)
//          --material   open with ?style=material
import { createServer } from 'node:http';
import { createReadStream, existsSync, mkdirSync, statSync } from 'node:fs';
import { createRequire } from 'node:module';
import { extname, join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

// `require` honours NODE_PATH, so a globally installed Playwright (as in the
// Claude Code container) is found without a local `npm install playwright`.
const { chromium } = createRequire(import.meta.url)('playwright');

const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(name);
  return i === -1 ? undefined : args[i + 1];
};
const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const outDir = resolve(flag('--out') ?? join(projectRoot, 'build/web_screenshots'));
const material = args.includes('--material');
const shotDir = outDir;
mkdirSync(shotDir, { recursive: true });

const mime = {
  '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.css': 'text/css', '.json': 'application/json', '.png': 'image/png',
  '.wasm': 'application/wasm', '.otf': 'font/otf', '.ttf': 'font/ttf',
  '.svg': 'image/svg+xml', '.ico': 'image/x-icon',
};

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

let shot = 0;
async function snap(page, name) {
  // Let Google Maps tiles settle, and dismiss the keyless "This page can't
  // load Google Maps correctly" dialog if it popped up.
  await page.waitForTimeout(2500);
  const ok = page.getByRole('button', { name: 'OK' });
  if (await ok.count()) await ok.first().click().catch(() => {});
  shot += 1;
  const file = join(shotDir, `${String(shot).padStart(2, '0')}_${name}.png`);
  await page.screenshot({ path: file });
  console.log(`saved ${file}`);
}

// Flutter renders buttons into the semantics tree as <flt-semantics
// role="button"> nodes once semantics is enabled (main_web.dart does that).
async function tap(page, label) {
  const button = page.getByRole('button', { name: label }).first();
  await button.waitFor({ state: 'attached', timeout: 15000 });
  try {
    await button.click({ timeout: 4000 });
  } catch {
    // Skewed/transformed buttons fail Playwright's stability check even
    // when the tap went through. If the button is gone, the screen already
    // changed; otherwise dispatch the click on the semantics node directly.
    if (await button.count()) await button.dispatchEvent('click', {}, { timeout: 3000 }).catch(() => {});
  }
  await page.waitForTimeout(900);
}

async function back(page) {
  const backButton = page.getByRole('button', { name: /back/i }).first();
  if (await backButton.count()) {
    await backButton.click();
  } else {
    await page.goBack();
  }
  await page.waitForTimeout(900);
}

async function main() {
  let server;
  let url = flag('--url');
  if (!url) {
    const dir = join(projectRoot, 'build/web');
    if (!existsSync(join(dir, 'index.html'))) {
      throw new Error(`${dir} is missing. Run: flutter build web -t lib/main_web.dart`);
    }
    server = await serve(dir);
    url = `http://127.0.0.1:${server.address().port}/`;
  }
  if (material) url += (url.includes('?') ? '&' : '?') + 'style=material';

  // Chromium must go through the container's HTTPS proxy to reach Google
  // Maps; the proxy CA is already in the browser's NSS trust store.
  const proxy = process.env.HTTPS_PROXY || process.env.https_proxy;
  const browser = await chromium.launch(
    proxy ? { proxy: { server: proxy, bypass: 'localhost,127.0.0.1' } } : {},
  );
  const page = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    hasTouch: true,
  });
  page.on('pageerror', (e) => console.error('page error:', e.message));
  page.on('console', (m) => { if (m.type() === 'error') console.error('console:', m.text()); });

  try {
    await page.goto(url, { waitUntil: 'load' });
    await page.getByRole('button', { name: 'All walks' }).first()
      .waitFor({ state: 'attached', timeout: 60000 });
    await page.waitForTimeout(1500);
    await snap(page, 'home');

    await tap(page, 'All walks');
    await snap(page, 'stage_select');
    await tap(page, /km/); // stage cards are buttons labelled with their stats
    await snap(page, 'stage_clear');
    await tap(page, 'All walks');
    await back(page);

    await tap(page, 'Places');
    await snap(page, 'spots');
    await back(page);

    await tap(page, 'Import');
    await tap(page, 'Load workouts');
    await snap(page, 'import');
    await back(page);

    // Long-press on the map marks a spot. The Google map (an HTML platform
    // view) reports a right click as the long press, the canvas mock needs a
    // real press-and-hold.
    try {
      await page.mouse.click(195, 250, { button: 'right' });
      await page.waitForTimeout(600);
      if (!(await page.getByRole('button', { name: 'Cancel' }).count())) {
        await page.mouse.move(195, 250);
        await page.mouse.down();
        await page.waitForTimeout(900);
        await page.mouse.up();
      }
      await snap(page, 'mark_spot');
      await tap(page, 'Cancel');
    } catch (error) {
      console.warn('skipping mark-spot dialog:', error.message);
    }

    await tap(page, 'Record');
    await snap(page, 'record_ready');
    await tap(page, 'Start recording');
    await page.waitForTimeout(11500); // the cubit samples the mock GPS every 5 s
    await snap(page, 'record_live');
    await tap(page, 'Stop recording');
    await snap(page, 'record_clear');
  } finally {
    await browser.close();
    server?.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

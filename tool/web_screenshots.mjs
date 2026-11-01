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
//          --design <journal|glass|blocks|clean>  capture a redesign proposal
//                       (home, walks list and a walk's detail, into <out>/<design>/)
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
const design = flag('--design');
const shotDir = design ? join(outDir, design) : outDir;
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
  await button.waitFor({ state: 'visible', timeout: 15000 });
  await button.click();
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
  if (design) url += (url.includes('?') ? '&' : '?') + `design=${design}`;

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
    if (design) {
      const walksLabel = { glass: 'See all', clean: 'See all' }[design] ?? 'All walks';
      await page.getByRole('button', { name: walksLabel }).first()
        .waitFor({ state: 'attached', timeout: 60000 });
      await page.waitForTimeout(1500);
      await snap(page, 'home');
      await tap(page, walksLabel);
      await snap(page, 'walks');
      if (design === 'clean') {
        // Walk rows are list tiles (buttons labelled with their stats).
        await tap(page, /km/);
        await snap(page, 'walk_detail');
      }
      return;
    }
    await page.getByRole('button', { name: 'View walked routes' }).first()
      .waitFor({ state: 'attached', timeout: 60000 });
    await page.waitForTimeout(1500);
    await snap(page, 'home_map');

    await tap(page, 'View walked routes');
    await snap(page, 'routes');
    await tap(page, /^Route: /); // list tiles are exposed as labelled buttons
    await snap(page, 'route_detail_seeded');
    await back(page);
    await back(page);

    await tap(page, 'View Point of interests');
    await snap(page, 'points_of_interest');
    await back(page);

    await tap(page, 'Record Walk');
    await snap(page, 'record_walk_idle');
    await tap(page, 'Start recording');
    await page.waitForTimeout(11500); // the cubit samples the mock GPS every 5 s
    await snap(page, 'record_walk_recording');
    await tap(page, 'Stop recording');
    await snap(page, 'record_walk_finished');
    await tap(page, 'View finished recording');
    await snap(page, 'route_detail_recorded');
    await back(page);
    await back(page);

    // Long-press on the map opens the "Add point of interest" dialog. The
    // Google map (an HTML platform view) reports a right click as the long
    // press, the canvas mock needs a real press-and-hold.
    try {
      await page.mouse.click(195, 250, { button: 'right' });
      await page.waitForTimeout(600);
      if (!(await page.getByRole('button', { name: 'Cancel' }).count())) {
        await page.mouse.move(195, 250);
        await page.mouse.down();
        await page.waitForTimeout(900);
        await page.mouse.up();
      }
      await snap(page, 'add_poi_dialog');
      await tap(page, 'Cancel');
    } catch (error) {
      console.warn('skipping add-POI dialog:', error.message);
    }

    await tap(page, 'Import last route');
    await page.waitForTimeout(1200);
    await snap(page, 'importer_authorized');
    await tap(page, 'Import walks');
    await page.waitForTimeout(1200);
    await snap(page, 'importer_workouts');
  } finally {
    await browser.close();
    server?.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

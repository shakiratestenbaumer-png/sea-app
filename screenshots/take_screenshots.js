const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const dir = '/home/yomo/mub/projects/experiment/ems/screenshots';

  // Desktop full page
  const desktop = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const dPage = await desktop.newPage();
  await dPage.goto('https://sea.supercharged.ch', { waitUntil: 'networkidle', timeout: 30000 });
  await dPage.waitForTimeout(3000);
  await dPage.screenshot({ path: `${dir}/desktop_full.png`, fullPage: true });
  console.log('✓ desktop_full.png');

  // Desktop viewport only
  await dPage.screenshot({ path: `${dir}/desktop_viewport.png`, fullPage: false });
  console.log('✓ desktop_viewport.png');

  // Mobile full page (iPhone 14 Pro size)
  const mobile = await browser.newContext({
    viewport: { width: 393, height: 852 },
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
    isMobile: true,
  });
  const mPage = await mobile.newPage();
  await mPage.goto('https://sea.supercharged.ch', { waitUntil: 'networkidle', timeout: 30000 });
  await mPage.waitForTimeout(3000);
  await mPage.screenshot({ path: `${dir}/mobile_full.png`, fullPage: true });
  console.log('✓ mobile_full.png');

  // Mobile viewport only
  await mPage.screenshot({ path: `${dir}/mobile_viewport.png`, fullPage: false });
  console.log('✓ mobile_viewport.png');

  // Privacy page
  await dPage.goto('https://sea.supercharged.ch/privacy', { waitUntil: 'networkidle', timeout: 30000 });
  await dPage.waitForTimeout(1000);
  await dPage.screenshot({ path: `${dir}/desktop_privacy.png`, fullPage: true });
  console.log('✓ desktop_privacy.png');

  await browser.close();
  console.log('Done!');
})();

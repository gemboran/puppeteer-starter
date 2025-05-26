import puppeteer from 'puppeteer';

// Check environment (development or production)
const isDev = process.env.NODE_ENV === 'development';
console.log(`Running in ${isDev ? 'development' : 'production'} mode`);

async function testPuppeteer() {
  console.log('Starting Puppeteer test...');
  
  const browser = await puppeteer.launch({
    executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || '/usr/bin/chromium',
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
    ],
    headless: isDev ? false : 'new',
    devtools: isDev ? true : false,
    defaultViewport: null,
  });
  
  try {
    console.log('Browser launched successfully');
    console.log(`Headless mode: ${isDev ? 'Disabled (browser visible)' : 'Enabled (browser hidden)'}`);
    console.log(`DevTools: ${isDev ? 'Enabled' : 'Disabled'}`);
    
    const page = await browser.newPage();
    console.log('New page created');
    
    await page.goto('https://example.com');
    console.log('Navigated to example.com');
    
    const title = await page.title();
    console.log(`Page title: ${title}`);
    
    const dimensions = await page.evaluate(() => {
      return {
        width: document.documentElement.clientWidth,
        height: document.documentElement.clientHeight,
        deviceScaleFactor: window.devicePixelRatio,
      };
    });
    console.log('Page dimensions:', dimensions);
    
    const screenshotPath = `/app/screenshots/test-${isDev ? 'dev' : 'prod'}-${Date.now()}.png`;
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`Screenshot saved to ${screenshotPath}`);
    
    // Wait for a moment to see the browser in dev mode
    if (isDev) {
      console.log('In dev mode - browser will remain open for 5 seconds...');
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
    
  } catch (error) {
    console.error('Error during test:', error);
  } finally {
    await browser.close();
    console.log('Browser closed');
  }
}

testPuppeteer().catch(console.error);
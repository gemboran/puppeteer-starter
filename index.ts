import puppeteer from "puppeteer";
import { mkdir } from "fs/promises";

// Check environment (development or production)
const isDev = process.env.NODE_ENV === "development";

async function main() {
  console.log(
    `Starting Puppeteer with Bun in ${isDev ? "development" : "production"} mode!`,
  );

  // Ensure screenshots directory exists
  try {
    await mkdir("/app/screenshots", { recursive: true });
    console.log("Screenshots directory created or already exists");
  } catch (error) {
    console.error("Error creating screenshots directory:", error);
  }

  // Launch browser using the system Chromium
  const browser = await puppeteer.launch({
    executablePath:
      process.env.PUPPETEER_EXECUTABLE_PATH || "/usr/bin/chromium",
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-gpu",
    ],
    headless: isDev ? false : true, // Headless false in dev mode, true otherwise
    devtools: isDev ? true : false, // Devtools true in dev mode, false otherwise
    defaultViewport: null,
  });

  try {
    // Create a new page
    const page = await browser.newPage();

    // Navigate to a website
    console.log("Navigating to example.com...");
    await page.goto("https://example.com");

    // Get the title
    const title = await page.title();
    console.log(`Page title: ${title}`);

    // Take a screenshot
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const screenshotPath = `/app/screenshots/screenshot-${timestamp}.png`;
    await page.screenshot({ path: screenshotPath });
    console.log(`Screenshot saved as ${screenshotPath}`);

    // Extract content
    const content = await page.evaluate(() => {
      return document.querySelector("h1")?.textContent;
    });
    console.log(`Page h1 content: ${content}`);
  } catch (error) {
    console.error("Error during Puppeteer execution:", error);
  } finally {
    // Close the browser
    await browser.close();
    console.log("Browser closed");
  }
}

main().catch(console.error);

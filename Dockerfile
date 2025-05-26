# Use the official Bun image as base
FROM oven/bun:latest

# Set working directory
WORKDIR /app

# Install system dependencies required for Puppeteer
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    ca-certificates \
    wget \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    NODE_ENV=production

# Copy package.json and lockfile first (for better caching)
COPY package.json ./
COPY bun.lockb ./

# Install dependencies and Puppeteer
RUN bun install && bun add puppeteer

# Copy the rest of the application
COPY . .

# Create directory for screenshots
RUN mkdir -p /app/screenshots

# Set permissions for the screenshots directory
RUN chmod -R 777 /app/screenshots

# Compile TypeScript with Node.js as the target
RUN bun build ./index.ts --outdir ./dist --target node

# Create an entrypoint script to handle NODE_ENV
RUN echo '#!/bin/sh\n\
\n\
# Define colors\n\
GREEN="\\033[0;32m"\n\
BLUE="\\033[0;34m"\n\
YELLOW="\\033[1;33m"\n\
CYAN="\\033[0;36m"\n\
NC="\\033[0m"\n\
\n\
echo -e "${BLUE}===========================${NC}"\n\
echo -e "${GREEN}Puppeteer with Bun${NC}"\n\
echo -e "${BLUE}===========================${NC}"\n\
echo -e "${YELLOW}CPU: Limited to 1 core${NC}"\n\
echo -e "${YELLOW}Memory: Limited to 1GB${NC}"\n\
echo -e "${BLUE}===========================${NC}"\n\
\n\
if [ "$NODE_ENV" = "development" ]; then\n\
  echo -e "${CYAN}Development Mode:${NC}"\n\
  echo -e "- Browser will be ${GREEN}visible${NC}"\n\
  echo -e "- DevTools are ${GREEN}enabled${NC}"\n\
  echo -e "- Perfect for debugging and development"\n\
else\n\
  echo -e "${CYAN}Production Mode:${NC}"\n\
  echo -e "- Browser will run in ${GREEN}headless mode${NC} (invisible)"\n\
  echo -e "- DevTools are ${GREEN}disabled${NC}"\n\
  echo -e "- Optimized for performance and automation"\n\
fi\n\
echo -e "${BLUE}===========================${NC}"\n\
echo -e "Starting application..."\n\
\n\
# Check for the screenshots directory\n\
if [ ! -d "/app/screenshots" ]; then\n\
  echo -e "Creating screenshots directory..."\n\
  mkdir -p /app/screenshots\n\
  chmod 777 /app/screenshots\n\
fi\n\
\n\
# Run the application\n\
exec bun run dist/index.js\n\
' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

# Set the command to run the application
CMD ["/app/entrypoint.sh"]
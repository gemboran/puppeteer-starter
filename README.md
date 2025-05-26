# Puppeteer with Bun

This project demonstrates how to run Puppeteer with Bun instead of Node.js, packaged in a Docker container. It supports both development and production modes with different browser configurations.

## Local Development

To install dependencies:

```bash
bun install
```

To run:

```bash
# Run in development mode (non-headless with DevTools)
bun run start:dev

# Run in production mode (headless without DevTools)
bun run start:prod

# Or using the default script (uses current NODE_ENV)
bun run start
```

## Docker Usage

### Using Docker Directly

Build the Docker image:

```bash
docker build -t puppeteer-bun .
```

Run the container:

```bash
# Run in development mode (non-headless with DevTools)
docker run --rm -e NODE_ENV=development puppeteer-bun

# Run in production mode (headless without DevTools)
docker run --rm -e NODE_ENV=production puppeteer-bun
```

### Using Docker Compose

The project includes a Docker Compose configuration with resource limits (1 CPU core and 1GB RAM):

```bash
# Start the container in development mode
docker compose --profile dev up

# Start the container in production mode
docker compose --profile prod up

# Run in detached mode
docker compose --profile dev up -d

# Stop the container
docker compose down
```

### Using the Run Script

The project includes a shell script for easy execution:

```bash
# Run in development mode (default)
./run.sh

# Run in production mode
./run.sh --prod

# Show help
./run.sh --help
```

### Docker Image Details

- Uses Bun instead of Node.js for faster performance
- Includes Chromium browser for Puppeteer
- Configured with necessary fonts and dependencies
- Sets up environment to skip Puppeteer's Chromium download
- Resource limits when using Docker Compose:
  - CPU: Limited to 1 core
  - Memory: Limited to 1GB
  - Reserved resources: 0.5 CPU cores and 512MB RAM

### Development vs Production Mode

The application supports two modes with different browser configurations:

#### Development Mode
- Browser launches in non-headless mode (visible browser window)
- DevTools are enabled for debugging
- Perfect for development and debugging
- Set via `NODE_ENV=development`

#### Production Mode
- Browser runs in headless mode (no visible window)
- DevTools are disabled for better performance
- Ideal for CI/CD pipelines and production environments
- Set via `NODE_ENV=production` (default if not specified)

This project was created using `bun init` in bun v1.1.43. [Bun](https://bun.sh) is a fast all-in-one JavaScript runtime.

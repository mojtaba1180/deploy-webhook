# Base image
FROM node:20-alpine AS base

# Install necessary packages
RUN apk add --no-cache libc6-compat git

# Setup pnpm environment
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN corepack prepare pnpm@latest --activate

# Dependencies stage
FROM base AS deps

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prefer-frozen-lockfile

# Builder stage
FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Ensure the deploy script is executable (if it exists and needs to be executable)
RUN chmod +x deploy_script.sh

# If you have a build step, add it here. If not, you can comment this out.
# For example: RUN pnpm build

### Production image runner
FROM base AS runner

# Set NODE_ENV to production
ENV NODE_ENV production

# Set correct permissions for nodejs user and don't run as root
RUN addgroup nodejs
RUN adduser -SDH runner
RUN mkdir -p /app
RUN chown runner:nodejs /app

# Copy files from builder stage
COPY --from=builder --chown=runner:nodejs /app ./

# Exposed port (for orchestrators and dynamic reverse proxies)
EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# Run the application
USER runner
CMD ["node", "webhook_server.js"]

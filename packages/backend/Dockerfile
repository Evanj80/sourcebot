# Stage 1: Build stage
FROM node:18.16.0-alpine3.18 AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package.json and package-lock.json for dependency install
COPY packages/backend/package.json packages/backend/package-lock.json* ./
COPY packages/backend/tsconfig.json ./

# Install only production dependencies and build dependencies for compiling
RUN npm ci

# Copy source code
COPY packages/backend/src ./src

# Build the TypeScript code
RUN npm run build


# Stage 2: Production image
FROM node:18.16.0-alpine3.18

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy built files
COPY --from=builder /app/dist ./dist

# Copy package.json for metadata (optional, useful for some tools)
COPY packages/backend/package.json ./package.json

# Expose application port
EXPOSE 4000

# Use non-root user
USER appuser

# Healthcheck for /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || wget -qO- http://localhost:4000/status || exit 1

# Entrypoint to handle signals properly
ENTRYPOINT ["/bin/sh", "-c"]

# Start the application
CMD ["node dist/index.js"]
### Stage 1: Build ###
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /app

# Copy only backend package.json and package-lock.json for dependency install
COPY packages/backend/package.json packages/backend/package-lock.json* ./

# Install dependencies
RUN npm ci

# Copy backend source code
COPY packages/backend/ ./

# Copy root-level config files
COPY configs/auth.json configs/basic.json configs/filter.json configs/multi-branch.json configs/self-hosted.json ./configs/

# Build the TypeScript project
RUN npm run build


### Stage 2: Production image ###
FROM node:18-alpine

# Create non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only production dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy built files
COPY --from=builder /app/dist ./dist

# Copy config files
COPY --from=builder /app/configs ./configs

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

USER appuser

# Expose ports
EXPOSE 4000 8080

# Set environment variables
ENV NODE_ENV=production
ENV PORT=4000

# Healthcheck for /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- --timeout=5 http://localhost:4000/health || exit 1

# Start the application
CMD ["node", "dist/index.js"]
### Stage 1: Build Stage ###
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy only package.json and package-lock.json to leverage Docker cache
COPY packages/backend/package.json packages/backend/package-lock.json* ./

# Install dependencies
RUN npm ci

# Copy the rest of the backend source code
COPY packages/backend/ ./

# Build the TypeScript code
RUN npm run build


### Stage 2: Production Stage ###
FROM node:18-alpine

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy only production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy built files
COPY --from=builder /app/dist ./dist

# Copy package.json for runtime metadata
COPY --from=builder /app/package.json ./package.json

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application ports
EXPOSE 4000 8080

# Set environment variables
ENV NODE_ENV=production
ENV PORT=4000

# Healthcheck to verify app is running
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || wget -qO- http://localhost:4000/status || exit 1

# Start the application
CMD ["node", "dist/index.js"]
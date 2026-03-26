# Build stage
FROM node:20-alpine AS build-stage

WORKDIR /app

# Install dependencies
COPY package*.json ./

# Use default npm registry, npmmirror is often slow outside of China
# Install dependencies with BuildKit cache mount
RUN --mount=type=cache,target=/root/.npm \
    npm install

# Copy source code and build
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine AS production-stage

# Copy the built files
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Replace the default Nginx config 
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# TODO: Adapt this Dockerfile for your runtime.
#
# Examples from existing apps:
#   cue.theor.net    — Bun server (single-stage runtime container)
#   home.theor.net   — Bun build -> nginx static (multi-stage)
#   index.theor.net  — nginx static only (no build step)

# === Build stage (uncomment if you have a build step) ===
# FROM node:22-alpine AS builder
# WORKDIR /app
# COPY package.json package-lock.json ./
# RUN npm ci
# COPY . .
# RUN npm run build

# === Runtime stage ===
# Option A: Server app (Node/Bun/etc.)
# FROM node:22-alpine
# WORKDIR /app
# COPY --from=builder /app .
# EXPOSE 3000
# CMD ["node", "index.js"]

# Option B: Static site behind nginx
# FROM nginx:alpine
# COPY nginx.conf /etc/nginx/conf.d/default.conf
# COPY --from=builder /app/dist /usr/share/nginx/html
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]

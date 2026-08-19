# syntax = docker/dockerfile:1

# Multi-stage build: compile the Vite SPA, then serve it with nginx which also
# reverse-proxies /api to the Rails backend container (same-origin, no CORS).

# --- Build stage -------------------------------------------------------------
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-slim AS build

WORKDIR /app

# Default SPA locale, baked in at build time (Vite inlines import.meta.env.*).
# Keep in sync with the backend's APP_DEFAULT_LOCALE. Defaults to "en".
# On Railway, set the build-time variable VITE_DEFAULT_LOCALE on the frontend service.
ARG VITE_DEFAULT_LOCALE=en
ENV VITE_DEFAULT_LOCALE=${VITE_DEFAULT_LOCALE}

# Install dependencies from the lockfile for reproducible builds.
COPY package.json package-lock.json ./
RUN npm ci

# Build the production bundle into /app/dist.
COPY . .
RUN npm run build

# --- Runtime stage -----------------------------------------------------------
FROM nginx:1.27-alpine AS runtime

# Backend the SPA proxies /api to. Overridden per-environment:
#   docker-compose -> http://web:3000
#   Railway        -> the backend service's private URL (http://<svc>.railway.internal:PORT)
ENV BACKEND_URL="http://web:3000"

# nginx.conf is a template; the entrypoint substitutes ${BACKEND_URL} and ${PORT}.
# Named 15-* so it runs before the stock 20-envsubst script (which it removes to
# avoid clobbering nginx runtime vars like $uri/$host).
COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY docker-entrypoint.sh /docker-entrypoint.d/15-render-template.sh
RUN chmod +x /docker-entrypoint.d/15-render-template.sh

# Copy the built SPA.
COPY --from=build /app/dist /usr/share/nginx/html

# nginx listens on $PORT (Railway sets it; defaults to 80 for compose).
ENV PORT=80
EXPOSE 80

# The stock nginx image's entrypoint runs everything in /docker-entrypoint.d
# then execs `nginx -g 'daemon off;'`.
CMD ["nginx", "-g", "daemon off;"]

# Fork (bobbyhyam/ynab-mcp-server): the container image our homelab runs behind
# agentgateway. It serves the streamable-HTTP entry point (dist/http.js) rather
# than stdio, because the gateway image is distroless and cannot spawn a stdio
# child. Kept as its own file, not an edit to upstream's Dockerfile, so merging
# an upstream tag never conflicts here.
#
# node:26-alpine is the active LTS line (Lithium) as of 2026-11-05: it and
# node:lts-alpine resolved to the digest below that day. Re-check that the two
# still match whenever the digest is refreshed.

FROM node:26-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94 AS build
WORKDIR /app
COPY package.json package-lock.json ./
# --ignore-scripts: no dependency install hooks (workerd, esbuild) in the build.
RUN npm ci --ignore-scripts
COPY tsconfig.json ./
COPY src ./src
RUN npx tsc && npm prune --omit=dev --ignore-scripts

FROM node:26-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94
WORKDIR /app
ENV NODE_ENV=production
# npm is not needed at runtime (the entrypoint is plain node) and its vendored
# modules are the usual source of scanner findings in node images.
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
# dist/http.js reads its version from package.json.
COPY package.json ./

USER node
ENV YNAB_MCP_HOST=0.0.0.0 PORT=8080
EXPOSE 8080
# Liveness only: /healthz never calls YNAB.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:8080/healthz').then((r) => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"
ENTRYPOINT ["node", "dist/http.js"]

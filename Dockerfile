FROM node:22-slim AS build

WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM node:22-slim

WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile --prod && pnpm add tsx
COPY --from=build /app/dist ./dist
COPY server ./server
COPY @/ ./@/

VOLUME /app/data
EXPOSE 3001

ENV NODE_ENV=production
ENV PORT=3001

CMD ["pnpm", "exec", "tsx", "server/index.ts"]

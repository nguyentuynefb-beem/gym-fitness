FROM node:24-alpine

WORKDIR /app

RUN mkdir -p /var/log/app && chown -R node:node /var/log/app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY --chown=node:node src ./src
COPY --chown=node:node views ./views
COPY --chown=node:node public ./public

ENV NODE_ENV=production
ENV PORT=3000

USER node
EXPOSE 3000
CMD ["node", "src/server.js"]
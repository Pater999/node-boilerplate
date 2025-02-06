#Build stage
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN PNPM_SPEC=$(node -pe "JSON.parse(fs.readFileSync('./package.json', 'utf8')).packageManager") \
    && npm i -g $PNPM_SPEC \
    && pnpm install --frozen-lockfile --ignore-scripts

COPY . .

RUN pnpm run build

#Production stage
FROM node:22-alpine AS production

WORKDIR /app

RUN useradd -ms /bin/bash app_user
USER app_user

COPY package.json pnpm-lock.yaml ./

RUN PNPM_SPEC=$(node -pe "JSON.parse(fs.readFileSync('./package.json', 'utf8')).packageManager") \
    && npm i -g $PNPM_SPEC \
    && pnpm install -P --frozen-lockfile --ignore-scripts

COPY --from=build /app/dist ./dist

CMD ["pnpm", "start"]
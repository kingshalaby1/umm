# ------------------------------
# Dockerfile for UMM
# Save as: Dockerfile (in umm repo root)
# ------------------------------

FROM elixir:1.18.3-otp-26-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base git npm nodejs

# set workdir
WORKDIR /app

# install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

# cache deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get && mix deps.compile

# build project
COPY . .
RUN MIX_ENV=prod mix compile

# build assets
RUN cd assets && npm install && npm run deploy
RUN MIX_ENV=prod mix phx.digest

# release
RUN MIX_ENV=prod mix release

# ------------------------------
# Runtime image
# ------------------------------
FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs
WORKDIR /app

COPY --from=build /app/_build/prod/rel/umm .

ENV REPLACE_OS_VARS=true \
    MIX_ENV=prod

ENTRYPOINT ["/app/bin/umm", "start"]


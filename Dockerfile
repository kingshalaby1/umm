# ------------------------------
# Dockerfile for UMM
# Save as: Dockerfile (in umm repo root)
# ------------------------------

FROM elixir:1.18.3-otp-26-alpine AS build

# Install system dependencies
RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Cache deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get && mix deps.compile

# Build application
COPY . .
RUN MIX_ENV=prod mix compile
RUN cd assets && npm install && npm run deploy
RUN MIX_ENV=prod mix phx.digest || true
RUN MIX_ENV=prod mix release

# ------------------------------
# Runtime image
# ------------------------------
FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs
WORKDIR /app

COPY --from=build /app/_build/prod/rel/umm .

ENV REPLACE_OS_VARS=true \
    MIX_ENV=prod \
    SECRET_KEY_BASE=super_secret_dummy_key \
    PHX_SERVER=true \
    PORT=4000 \
    PHX_HOST=0.0.0.0

ENTRYPOINT ["/app/bin/umm", "start"]

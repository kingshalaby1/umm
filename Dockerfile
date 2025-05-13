# ------------------------------
# Dockerfile for UMM
# Save as: Dockerfile (in umm repo root)
# ------------------------------

FROM elixir:1.18.3-otp-26-alpine AS build

# Install build tools and Node.js for asset handling
RUN apk add --no-cache build-base git npm nodejs

WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Cache deps
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get && mix deps.compile

# Build app source
COPY . .
RUN MIX_ENV=prod mix compile

# Build frontend assets
RUN [ -d assets ] && cd assets && npm install && npm run deploy || echo "Skipping asset build"
RUN MIX_ENV=prod mix phx.digest

# Release the app
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

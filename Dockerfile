ARG NODEJS_VERSION
ARG ELIXIR_VERSION
ARG ALPINE_VERSION=3.9



FROM elixir:${ELIXIR_VERSION}-alpine as deps-getter

ENV MIX_ENV=${MIX_ENV}
ENV HOME=/opt/app
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force

COPY .tool-versions mix.exs mix.lock $HOME/
RUN mix do deps.get --only=$MIX_ENV



FROM node:${NODEJS_VERSION}-alpine as asset-builder

ENV HOME=/opt/app
WORKDIR $HOME/assets

COPY --from=deps-getter /opt/app/deps/ $HOME/deps/
COPY assets/package.json assets/package-lock.json $HOME/assets/
RUN npm install --no-audit --silent

COPY assets/ $HOME/assets/
RUN npm run deploy



FROM elixir:${ELIXIR_VERSION}-alpine as builder

ARG APP_NAME
ARG APP_VERSION

ENV MIX_ENV=prod
ENV HOME=/opt/app
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force

COPY --from=deps-getter /opt/app/deps/ $HOME/deps/
COPY .tool-versions mix.exs mix.lock $HOME/
RUN mix deps.compile

COPY config/ $HOME/config/
COPY lib/ $HOME/lib/
COPY priv/ $HOME/priv
RUN mix compile

COPY --from=asset-builder /opt/app/priv/static/ $HOME/priv/static/
RUN mix phx.digest

COPY rel/ $HOME/rel
RUN mix release --verbose



FROM alpine:$ALPINE_VERSION

ARG APP_NAME
ARG APP_VERSION

ENV APP_NAME=$APP_NAME
ENV MIX_ENV=prod
ENV HOME=/opt/app
WORKDIR $HOME

RUN apk update && apk add --no-cache \
    openssl-dev \
    bash

ENV REPLACE_OS_VARS=true \
    APP_NAME=$APP_NAME

COPY docker/entrypoint.sh $HOME/
COPY --from=builder "/opt/app/_build/$MIX_ENV/rel/$APP_NAME/releases/$APP_VERSION/$APP_NAME.tar.gz" release.tar.gz
RUN tar xfz release.tar.gz

ENTRYPOINT ["./entrypoint.sh"]
CMD ["foreground"]

# assumes js assets are already compiled
FROM elixir:alpine

ARG DB_NAME
ARG DB_PASSWORD
ARG DB_USER_NAME
ARG PORT
ARG MIX_ENV

RUN apk update
RUN apk add bash
ENV REPLACE_OS_VARS=true TERM=xterm PORT=$PORT MIX_ENV=$MIX_ENV

COPY . .

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix do deps.get, deps.compile, compile
RUN mix phx.digest
RUN mix release --env=prod --verbose

EXPOSE $PORT

CMD ["bash", "migrate_and_start.sh"]

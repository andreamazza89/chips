# assumes js assets are already compiled
FROM elixir:alpine
RUN apk update
RUN apk add bash
ENV MIX_ENV=prod REPLACE_OS_VARS=true TERM=xterm PORT=8080

COPY . .

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix do deps.get, deps.compile, compile
RUN mix phx.digest
RUN mix release --env=prod --verbose

EXPOSE 8080
EXPOSE 5432

CMD ["bash", "migrate_and_start.sh"]

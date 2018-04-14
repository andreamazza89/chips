FROM elixir:1.6.4

WORKDIR /chips-app

# Get the source code
COPY . .

# Update apt-get index and install bash
RUN apt-get update
RUN apt-get install bash

# Install node
RUN apt-get install sudo
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install nodejs

# Prepare the static assets
RUN cd assets && \
  npm install && \
  ./node_modules/brunch/bin/brunch build

# Now use a much slimmer elixir base image to run the app on
FROM elixir:alpine

WORKDIR /chips-app

COPY --from=0 /chips-app /chips-app

# Fetch Elixir dependencies and compile
RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix do deps.get, deps.compile, compile

# Install bash
RUN apk update && apk --no-cache --update add bash

CMD ["bash", "migrate_and_start.sh"]

FROM elixir:1.6.4

WORKDIR /chips-app

# Get the source code
COPY . .

# Set environment variables from build command input
ARG DB_NAME
ARG DB_PASSWORD
ARG DB_USER_NAME
ARG PORT
ARG MIX_ENV

# Update apt-get index and install bash
RUN apt-get update
RUN apt-get install bash
ENV REPLACE_OS_VARS=true TERM=xterm PORT=$PORT MIX_ENV=$MIX_ENV DB_NAME=$DB_NAME DB_PASSWORD=$DB_PASSWORD DB_USER_NAME=$DB_USER_NAME

# Install node
RUN apt-get install sudo
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install nodejs

# Fetch Elixir dependencies and compile
RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix do deps.get, deps.compile, compile

# Prepare the static assets
RUN cd assets && \
  npm install && \
  ./node_modules/brunch/bin/brunch build

# Now use a much slimmer elixir base image to run the app on
FROM elixir:alpine

COPY --from=0 /chips-app .

# Install Hex
RUN mix local.hex --force

# Set environment variables from build command input
ARG DB_NAME
ARG DB_PASSWORD
ARG DB_USER_NAME
ARG PORT
ARG MIX_ENV

RUN apk update && apk --no-cache --update add bash
ENV REPLACE_OS_VARS=true TERM=xterm PORT=$PORT MIX_ENV=$MIX_ENV DB_NAME=$DB_NAME DB_PASSWORD=$DB_PASSWORD DB_USER_NAME=$DB_USER_NAME

EXPOSE $PORT

CMD ["bash", "migrate_and_start.sh"]

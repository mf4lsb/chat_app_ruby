# FROM ruby:3.2-bullseye as base

# RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs

# WORKDIR /docker/app

# RUN gem install bundler

# COPY Gemfile* ./

# RUN bundle install

# ADD . /docker/app

# ARG DEFAULT_PORT 3000

# EXPOSE ${DEFAULT_PORT}

# CMD [ "bundle","exec", "puma", "config.ru"] 
# # CMD ["rails","server"]

# Stage 1: Build dependencies
FROM ruby:3.2-bullseye AS builder

WORKDIR /tmp/app

RUN apt-get update -qq && \
    apt-get install -y build-essential apt-utils libpq-dev nodejs

COPY Gemfile* ./

RUN gem install bundler --no-document

# Install application gems
RUN bundle install --no-cache --no-document

# Copy only the application code and Gemfile.lock
COPY --from=builder /tmp/app/Gemfile.lock /docker/app/Gemfile.lock
COPY . /docker/app

# Stage 2: Slim runtime image
FROM ruby:3.2-alpine AS runner

WORKDIR /docker/app

COPY --from=builder /docker/app .

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

CMD [ "bundle", "exec", "puma", "config.ru"]
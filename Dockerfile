# Use the official Ruby image with version 3.4.4 as the base image
FROM ruby:3.4.4

# Set the working directory in the container
WORKDIR /app

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install OS-level dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# Copy the Gemfile and Gemfile.lock into the image and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Install JavaScript dependencies
COPY package.json package-lock.json ./
RUN npm install

# For temporary testing in ECS
ENV NEW_RELIC_AGENT_ENABLED=false

# Copy the full Rails app codebase
COPY . .

# Precompile all assets
# RUN bundle exec rake assets:precompile

# Copy ssl pem keys
# COPY /etc/letsencrypt/amplify.gov.au/fullchain.pem .
# COPY /etc/letsencrypt/amplify.gov.au/privkey.pem .

# Expose port 3000 to the host
EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

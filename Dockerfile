# Use the official Ruby image with version 3.0.0 as the base image
FROM ruby:3.0.0

# Set the working directory in the container
WORKDIR /app

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install essential dependencies
RUN apt-get update \
    && apt-get install -y \
        nodejs \
        npm \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy the Gemfile and Gemfile.lock into the image and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Run npm install
RUN npm install

# Precompile all assets
RUN bundle exec assets:precompile

# Copy ssl pem keys
COPY /etc/letsencrypt/amplify.gov.au/fullchain.pem .
COPY /etc/letsencrypt/amplify.gov.au/privkey.pem .

# Copy the rest of the application code into the image
COPY . .

# Expose port 3000 to the host
EXPOSE 3000

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

# Copy the rest of the application code into the image
COPY . .

# Expose port 3000 to the host
EXPOSE 3000

# Start the Rails server when the container starts
CMD ["rails", "server", "-b", "0.0.0.0"]

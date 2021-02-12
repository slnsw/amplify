#!/bin/bash

CONFIG=<<EOF
development:
  host: database
  adapter: postgresql
  encoding: unicode
  username: rails
  password: rails
  database: rails
  port: 5432
  pool: 5
  timeout: 5000
EOF

echo $CONFIG > ../config/database.yml


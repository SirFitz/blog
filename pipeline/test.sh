#!/bin/bash

mix local.hex --force \
    && mix local.rebar --force
mix deps.get
MIX_ENV=prod mix deps.compile --force
MIX_ENV=prod mix compile --force

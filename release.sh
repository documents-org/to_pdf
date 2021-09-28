#!/bin/bash
source .env.prod

export SECRET_KEY_BASE=oHtWgTihTvk17EAMCpmyvsymnpL9YBdsM+E/9IzJrcT7hZQW/4mGkO+ern0hmL8o
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

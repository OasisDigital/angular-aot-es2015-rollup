#!/bin/bash
set -e

# See README.md for more explanation

# Doing all this with package scripts and so on would be more
# cross-platform, but harder to talk through when shown on the screen
# during a presentation.

# Cleanup from any past runs
rm -rf app/aot www/bundle.js* www/materialize www/*.js www/*.map www/*.br build
mkdir -p build

# AOT and TypeScript compile
node_modules/.bin/ngc

# Tree-shake bundle the results
node_modules/.bin/rollup -c

# Use Brotli, if available, to see the best-case network transfer size
if hash bro 2>/dev/null; then
  bro --input www/bundle.js --output www/bundle.js.br
fi

# Gather CSS
cp -R node_modules/materialize-css/dist www/materialize

echo "AOT output size"
ls -l www/bundle.js www/bundle.js.br

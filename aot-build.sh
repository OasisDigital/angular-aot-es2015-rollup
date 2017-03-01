#!/bin/bash
set -e

# See README.md for more explanation

# Cleanup from any past runs
rm -rf app/aot
rm -rf www/bundle.js*
rm -rf www/materialize
rm -f www/*.js
rm -f www/*.br
rm -rf build
mkdir -p build

# AOT and TypeScript compile
node_modules/.bin/ngc

# Tree-shake bundle the results
node_modules/.bin/rollup -c

# Use Brotli, if available, to see the best-case network transfer size
if hash bro 2>/dev/null; then
  bro --input www/bundle.js --output www/bundle.js.br
fi

# Gather unavoidable polyfills
cp node_modules/core-js/client/shim.min.js www
cp node_modules/zone.js/dist/zone.min.js www

# Gather CSS
cp -R node_modules/materialize-css/dist www/materialize

echo "AOT output size"
ls -l www/bundle.js www/bundle.js.br

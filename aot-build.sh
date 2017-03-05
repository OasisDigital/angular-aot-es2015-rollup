#!/bin/bash
set -e

# See README.md for more explanation

# Cleanup from any past runs
rm -rf app/aot
rm -rf www/bundle.*
rm -rf www/materialize
rm -f www/*.js
rm -f www/*.map
rm -f www/*.br
rm -rf build
mkdir -p build

# AOT and TypeScript compile
node_modules/.bin/ngc

# Tree-shake bundle the results
node_modules/.bin/rollup -c

# ES2015->ES5 and minify with Clojure Compiler, the old fashioned Java
# implementation, see README.
OPTS=(
  "--language_out=ES5"
  "--js_output_file=www/bundle.min.js"
  "--create_source_map=%outname%.map"

  # Don't include ES6 polyfills, we are using CoreJS
  "--rewrite_polyfills=false"

  # Include the unavoidable polyfills, to get them in the same file,
  # even though they are already minified:
  "node_modules/core-js/client/shim.min.js"
  "node_modules/zone.js/dist/zone.min.js"

  # Process the rollup output:
  "www/bundle.js"
)

closureFlags=$(mktemp)
echo ${OPTS[*]} > $closureFlags
java -jar node_modules/google-closure-compiler/compiler.jar --flagfile $closureFlags

# Gather CSS
cp -R node_modules/materialize-css/dist www/materialize

# Use Brotli, if available, to see the best-case network transfer size
if hash bro 2>/dev/null; then
  bro --input www/bundle.min.js --output www/bundle.min.js.br
  echo "AOT output size"
  ls -l www/bundle.min.*
fi

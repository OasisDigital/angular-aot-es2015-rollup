// See README.md for more explanation

import nodeResolve from '@oasisdigital/rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import sourcemaps from 'rollup-plugin-sourcemaps';

// Beware of:
// https://github.com/maxdavidson/rollup-plugin-sourcemaps/issues/33

export default {
  entry: 'build/aot-main.js', // entry point for the application
  dest: 'www/bundle.js',
  sourceMap: true,
  useStrict: false,
  format: 'iife', // ready-to-execute form, to put on a page
  onwarn: function (warning) {
    // Skip certain warnings
    if (warning.code === 'THIS_IS_UNDEFINED') { return; }
    console.warn(warning.message);
  },
  plugins: [
    sourcemaps(),
    nodeResolve({
      es2015: true,  // Angular es2015 package.json field
      module: false, // disable the ES5-in-ES2015 modules we aren't using.
      browser: true  // Not needed for this example, needed for certain 3p libs
    }),
    commonjs({
      // make it possible to find these individual intra-package files
      include: [
        'node_modules/core-js/**',
        'node_modules/zone.js/**',
        'node_modules/rxjs/**'
      ]
    })
  ]
}

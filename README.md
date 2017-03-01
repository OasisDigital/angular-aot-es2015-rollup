# Angular 4 rc.1 AOT Example with es2015 ESM, Rollup, Closure Compiler

Kyle Cordes, Oasis Digital

March 2017

## Background

Most Angular users treated AOT as a future curiosity when Angular
reached production release in the summer of 2016. As of late fall 2016
though, many (particularly those working on larger applications) have
been much more eager and interested.

At the same time, there were various technical limitations and how
well AOT could work early on, some of them related to the CommonJS
package format ubiquitous on NPM.

Fortunately, the tools and libraries have matured greatly, making it
much easier than before to get results with AOT. Further, Angular
itself has matured greatly, and AOT runs more quickly and produce a
smaller output than ever before. At the same time, the Angular core
team has recently started shipping the libraries and formats more and
more suitable for efficient production bundling, with tree shaking,
with AOT.

This repo demonstrates one such tool stack, Rollup. Rollup has
received less attention recently compared to Webpack, because the
latter is used inside of the official Angular CLI.

## Kit

Here are the libraries and elements used in this example.

### Angular 4.0.0-rc.1

As of the end of February 2013, this is the very latest, and it is
also the first release to ship with the new packaging of libraries.

Angular 4 AOT both compiles and executes more quickly and with smaller
size than Angular 2. This alone should provide ample motivation for
users to adopt version 4 quickly. (Oasis Digital now teaches Angular
Boot Camp with Angular 4.)

### AOT (ngc)

AOT is executed using the ngc command line tool. Its configuration is
in `tsconfig.json`. The critical settings are:

```
    "target": "es2015",
    "module": "es2015",
```

As ngc wraps the TypeScript compiler and provides TypeScript
compilation, these settings mean the output will be ES2015 code in
ES2015 modules - the same as the new Angular es2015 FESM packaging.

### ES2015 FESM packaging

<https://github.com/angular/angular/blob/master/CHANGELOG.md#es2015-builds>

This means "flat ES2015 modules containing ES2105 code". "Flat" means
that the numerous separate files that comprise the Angular source code
have been combined into a single large file per major Angular library,
removing all the overhead of how those modules would have had to be
wired together at run time otherwise.

There is also a packaging included which uses these type of "FESM"
modules, but with ES5 code inside. We picked the most advanced option
for optimal Rollup processing. Rollup can do a better job with more
information, and that information is more present using the latest
packaging and source code format.

### Rollup

<http://rollupjs.org/>

Rollup is widely considered among the best current options for space
efficient production module bundling. I don't have a comparison handy
to benchmark it against Webpack 2.0, unfortunately.

"Current options" turns out to exclude numerous older module bundlers.
Only the most current ones can bundle ES2015 modules.

### "@oasisdigital/rollup-plugin-node-resolve" package

<https://www.npmjs.com/package/@oasisdigital/rollup-plugin-node-resolve>

While Rollup can understand ES2015 modules, it needs help from a
plug-in to understand the node_modules directory and file structure.
Unfortunately, the shipping version of the relevant plug-in, as of the
end of February 2017, cannot understand the new "es2015" field in the
package.json file, used by the Angular packages to locate the ES2015
FESM code.

I have written a pull request to add the feature. And in the meantime,
published this temporary fork which adds the feature. You can see its
use in the `rollup.config.js` file.

### Closure Compiler (Java edition)

<https://github.com/google/closure-compiler/>

While for optimal bundling it is important to use ES2015 code as far
as possible through the build process, I was looking for output:

* Suitable for older browsers, which is to say, ES5.
* Minified.
* As a single file.

There are various alternative tools to do this. In an earlier edition
of this project I used Buble (rather than the more popular Babel, for
various reasons), and uglify, both in the form of Rollup plug-ins.

However, the current leader for producing the smallest results appears
to still be the Google Closure Compiler, which is much older than the
competing tools, and written in (horrors!) Java. It is robust, proven,
performant.

#### Why not the Closure Compiler JavaScript editio?n

I tried this first, as would avoid a Java dependency. Unfortunately,
there appears to be a limitation or bug which makes it unable to
process the FESM bundles provided by the Angular project. Those files
contain a Unicode character U+0275, rejected by
Closure-Compiler-in-JavaScript JavaScript as "not a valid identifier
start char".

### Brotli

Brotli is the new gzip - the new top-of-the-line choice for
compressing web assets for download. By adding a step using Brotli, we
can see immediately just how small the compiled compressed JavaScript
results will be.

`brew install brotli` (or whatever, for your OS)

## Results

```
npm install
./aot-build.sh
npm start
```

Then experiment with the application in your browser.

The output size, **inclusive** of mandatory polyfills:

```
-rw-r--r--+ 1 kcordes  staff  422550 Mar  1 08:20 www/bundle.min.js
-rw-------+ 1 kcordes  staff   94633 Mar  1 08:20 www/bundle.min.js.br
```

This application uses several of the Angular main modules, and various
RxJS operators. The resulting JavaScript "on the wire" is 94K. This
seems quite satisfactory.

To understand where the bytes come from:

```
npm run explore
```

This looks at the bundle size prior to the Closure step, because of a
weakness in source map processing (which it is possible to work around
some external processing, not yet done here).

## Limitation and future improvements

These results are good, but there are better results readily
obtainable once all of the necessary tooling is in place.
Specifically, for best results it is necessary for the steps all the
way through the module bundling, tree shaking, and minification to
understand the data types.

To do so, we would replace the simplistic use of the Closure Compiler
here (where does processing a single bundle after the tree shaking was
done by rollup) with a full use of Closure "advanced optimizations".
However, this is still awaiting some additional tooling adjustments to
propagate types all the way from TypeScript into the type system
understood by Closure Compiler.

To follow those efforts:

<https://github.com/alexeagle/closure-compiler-angular-bundling>

Unfortunately the running example there is a smaller, simpler angular
application than the one here; so you can't directly compare the
sizes. Still, it is safe to assume that once the full type driven
optimization pipeline is done, the result is significantly better than
what is achieved by the Rollup-plus-Closure solution.

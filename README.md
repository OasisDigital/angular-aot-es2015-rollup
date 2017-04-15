# Angular 4 AOT Example with es2015 FESM, Rollup, Buble, Uglify

Kyle Cordes, Oasis Digital

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

### Angular 4

As of the April 2017, this is the very latest, and it ships with the
new FESM packaging of the libraries.

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

### ES2015 FESM packaging, sometimes called FESM15

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
to benchmark it against Webpack 2.x, unfortunately.

"Current options" excludes numerous older module bundlers. Only the
most current ones can bundle ES2015 modules.

### rollup-plugin-node-resolve-angular

<https://www.npmjs.com/package/rollup-plugin-node-resolve-angular>

While Rollup can understand ES2015 modules, it needs help from a
plug-in to understand the node_modules directory and file structure.

`rollup-plugin-node-resolve` doesn't support the new Angular-specific
way of marking ES2015 FESM code, the fork above at this capability.

To work around that, I have published and alternate variation of this
plug-in, `rollup-plugin-node-resolve-angular`. It is very likely that
the standard Rollup plug-in will include support for whatever standard
is eventually agreed to, whether that is the current `es2015` package
field or something different.

### Buble

<https://buble.surge.sh/guide/>

While for optimal bundling it is important to use ES2015 code as far
as possible through the build process, with this kit I was unable to
reach all the way to browser shippable code with ES2015, even though
the current versions of major browsers have extensive ES2015 support.
Why?

Because there is a current hole in the ecosystem, as far as I can
tell. There isn't a minifier are available which consumes and produces
ES2015 code.

So to keep the process moving, we need a compiler ES2015->ES5. Choices
include:

* Babel
  * The standard, the default almost everyone uses.
  * High quality, very complete.
  * After its extreme modularization a couple years so,, It ships a
    large number of small node packages and files to produce a working
    ES2015 compiler.
  * Not so fast.
  * Most importantly, there is currently a bug, most likely in the
    Rollup Babel plug-in, in which it believes that it is not been
    configured correctly to disregard modules.

* Buble
  * Small, fast, few features.
  * Written by the author of Rollup, so likely to work well together.
  * It has one relevant limitation here around for-of loops, but it
    turns out that the TypeScript compilation emits usages of this
    loop in a form that works fine with the Buble limitation.
    ("dangerousForOf")
  * No current bug inhibiting it from working.

* TypeScript compiler
  * In the past I have successfully used this for the ES2015-to-ES5
    step, I believe initially nudged in this direction by an AOT
    example published by Rob Wormald.
  * Run pretty fast, installs quickly, arrives in the form of one
    package with no dependencies.
  * Unpopular for mere ES2015-to-ES5.

* Closure Compiler
  * Great tool, performs both the compilation and (best available,
    usually) minification.

For the ES2015-to-ES5 step, I will probably try TypeScriptnext time.
Buble worked great for this time.

### Uglify

<http://lisperator.net/uglifyjs/>

Uglify is by far the most common JavaScript minifier. It worked fine
for this use without any trouble. But read the later section for
important limitations.

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

This application uses several of the Angular main modules, and various
RxJS operators. The resulting JavaScript "on the wire" is 88K. This
seems quite satisfactory. Size includes the polyfills in the bundle.

```
-rw-r--r--+ 1 kcordes  staff  364631 Apr 15 10:49 www/bundle.js
-rw-------+ 1 kcordes  staff   79711 Apr 15 10:49 www/bundle.js.br
```

To understand where the bytes come from:

```
npm run explore
```

## Limitation and future improvements

I expect an ongoing strong trend toward lazy loading in the Angular
developer community. Unfortunately, Rollup does not currently support
code splitting and therefore cannot produce a set of bundles for lazy
loading but only a single bundle for upfront loading. Therefore Rollup
seems suitable for Angular libraries, and for small Angular
applications but not for large applications.

There are efforts well under way primarily at Google to use Google
Closure Compiler for ES2015-to-ES5, bundling, tree shaking,
minification, all with one tool. This produces smaller results, and
should eventually support code splitting for lazy loading.

To follow those efforts:

<https://github.com/alexeagle/closure-compiler-angular-bundling>

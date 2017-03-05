# Angular 4 rc.1 AOT Example with es2015 ESM, Rollup, Buble, Uglify

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

So to keep the process moving, we need a compiler ES2015->ES5. The choices:

* Babel
  * The standard, the default almost everyone uses.
  * After its extreme modularization in the latest couple of versions,
    It ships a very surprisingly large number of node packages and
    files to produce a working ES2015 compiler.
  * Not so fast.
  * Most importantly, there is currently a bug, most likely in the
    Rollup Babel plug-in, in which it believes that it is not been
    configured correctly to disregard modules.

* Buble
  * Small, fast, few feature alternative.
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

* Closure Compiler
  * Great tool, performs both the compilation and (best available,
    usually) minification.
  * I'll make a branch and use it, alternative to this stack.

I will probably try TypeScript in this ES2015-to-ES5 step next time.
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
-rw-r--r--+ 1 kcordes  staff  404969 Mar  4 19:18 www/bundle.js
-rw-------+ 1 kcordes  staff   85831 Mar  4 19:18 www/bundle.js.br
```

To understand where the bytes come from:

```
npm run explore
```

## Limitation and future improvements

These results are good, but there are better results readily
obtainable once all of the necessary tooling is in place.
Specifically, for best results it is necessary for the steps all the
way through the module bundling, tree shaking, and minification to
understand the data types.

As I understand, there are efforts well under way primarily at Google
to put the necessary type wiring in place so that the Google Closure
Compiler can be used in leiu of Rollup/Buble/Uglify. (Closure offers
"advanced optimizations" which are still (in spite of being a years
old tool) superior.) When complete this wiring should yield notably
better overall results, with fewer different tools involved.

To follow those efforts:

<https://github.com/alexeagle/closure-compiler-angular-bundling>

Unfortunately the running example there is a smaller, simpler angular
application than the one here; so you can't directly compare the
sizes.

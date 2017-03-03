---
title: "Automated frontend development with npm as a build tool"
date: "2016-03-20T10:29:16Z"
type: "article"
categories: ["Development"]
tags: ["javascript", "gulp", "node", "nodejs", "npm"]
---

I need to confess - I like Javascript. I hate browsers. I love automation & build tools. I use Javascript in my projects
extensively. I've been using Javascript build tools for a long time. First I've been using Grunt for a long time, then
switched to Gulp. Recently I realized - sometimes Gulp is overhead. For every single Gulp task you need a plugin.
Gulp plugins add an extra layer as most tools already have a command line interface. In this post I'll try to illustrate
how to reduce the amount of dependencies and create an automated development environment using npm scripts.

Developer can define script in the `package.json` file easily:

*package.json*
```
{
  "scripts": {
    "foo": "foo -arg1 -arg2"
  }
}
```

After that, `foo` script can be executed with `npm run foo` command. Quite simple, huh?

## Examples

But that task was relatively simple, what about some real world usage? Let's take a look at Browserify and let's try to
tun it via Gulp & via npm scripts.

*package.json*
```
{
  "scripts": {
    "browserify": "browserify -d -t reactify ./entry.js -o ./output.js"
  }
}
```

*Gulpfile.js*
```
module.exports = function(grunt) {
  grunt.initConfig({
    browserify: {
      options: {
        debug: true,
        transform: ['reactify']
      },
    files: {
      './output.js': './entry.js'
    }
  },
});

grunt.loadNpmTasks('grunt-browserify');
grunt.registerTask('default', ['browserify']); };
```

The first snippet looks *a bit* better, doesn't it? What about some other tool? Let's take a look at Webpack example.

*package.json*
```
{
  "scripts": {
    "build:js": "webpack",
    "watch:js": "npm run build:js -- --watch"
  }
}
```

Now it's time for a **real** real-world example, a `package.json` file for [react-router-bootstrap](https://github.com/react-bootstrap/react-router-bootstrap)
library.

```
{
  "scripts": {
    "prepublish": "npm run build",
    "build": "rimraf lib && babel src -d lib && webpack && webpack -p && npm run bower-prepare",
    "test": "npm run lint && karma start --single-run",
    "tdd": "karma start",
    "visual-test": "open http://localhost:8080/ && webpack-dev-server --config webpack.visual.config.babel.js",
    "lint": "eslint *.js src test",
    "bower-prepare": "babel-node scripts/bower-prepare.js",
    "release": "release"
  }
}
```

As can be seen in the above example, almost complex set up is relatively easy to write, understand & maintain while
using npm scripts.

## Lifecycle scripts
Another huge advantage of using npm as a build tool is the fact that npm supports the lifecycle scripts of the "scripts"
property of package.json. You can find the complete reference in the [npm docs](https://docs.npmjs.com/misc/scripts).
Lifecycle scripts might be used to automate `pre-` and `post-` task scripts.

```
npm version patch -m "Upgrade to %s"
```

*package.json*
```
{
  "scripts": {
    "preversion": "npm run test && npm run build”,
    "postversion": "npm publish && git push --tags"
  }
}
```

As can be seen in the above examples, lifeback scripts might be a real powerful tool to automate any `pre-` and `post-`
task tasks.

## Sub-tasks
Every single good automation system should be as simple as possible. Configuration should be easy to understand and even
easier to maintain. As maintaining shell commands *might* be relatively hard for non-geeky person, it's important to
create simple scripts that can be executed subsequently or "merged" runtime.

Let's take a look at the example of **bad practices**:
```
{
  "scripts": {
    "test": "eslint ./src/**/*.js && jscs ./src/**/*.js && karma start"
  }
}
```

Why I consider the above example as a bad practice? It does not give the developer to execute the command separately
(in this example a separate script will be required to run `eslint` or `karma` separately). It's also hard to read and
maintain.

Now the second version of the same *package.json* file:
```
{
  "scripts": {
    "test": "npm run eslint & npm run jscs & npm run karma",
    "eslint": "eslint ./src/**/*.js",
    "jscs": "jscs ./src/**/*.js",
    "karma": "karma start"
  }
}
```

I think the second version is way better as it gives the developer possibility to run every single command separately.
Additionally it follows the *single responsibility principle* as every single task is responsible only for running single
tool according to it's name. From the other hand, the `test` scripts runs *all* tests related scripts.

## Drawbacks
Using npm scripts as a build tool is a fantastic approach, however there are few drawbacks that need to be mentioned:

  + less extensible code - while keeping scripts clean & easy to maintain, they become less extensible
  + multi-platform compatibility - one does not simply use `rm` on Windows
  + lack of CLI - some tools does not provide any CLI.

## Rationale
I don't want to negate the sense of build tools existence. The idea of this blog post is to show an alternative approach
which might be *better* solution for common problems. As a build tool already depends on a CLI library, why introducing
an extra layer? Why not try to drop all *intermediate* dependencies and communicate with a tool directly via CLI?

I recently switched to npm scripts in my every single personal project & to be honest I don't even think about switching
back to Gulp or Grunt anymore.
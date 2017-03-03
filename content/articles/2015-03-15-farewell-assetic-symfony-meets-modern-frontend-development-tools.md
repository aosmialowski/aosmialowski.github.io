---
title: "Farewell Assetic. Symfony meets modern frontend development tools"
date: "2015-03-15T00:40:55Z"
type: "article"
categories: ["Development"]
tags: ["php", "symfony", "javascript"]
---

Being a programmer who works mainly with Symfony taught me using the best tools available - modern, well tested and widely used. Being honest - I don't like Assetic for many reasons. Regardless of my reasons, I've decided to not touch Assetic any more.

In this post, I will concentrate about the most popular stack:

+ Grunt - for automated tasks
+ Bower - for dependency management
+ RequireJS - for writing modular Javascript code (and manage modules dependencies).

### Introduction

There are many advantages of using this approach:

+ frontend developers can use the tools of their choice
+ assets are not coupled with the core of the application (Assetic forces assets to be part of the bundle [^1]). You can use Git submodules or independent repository for your assets.
+ frontend changes does not require application update [^2]
+ speeding up the process - Assetic is ridiculously slow in big projects (large amount of assets) especially in dev environment
+ modular Javascript code (thanks to RequireJS)
+ ease of use - the configuration requires one single command to
+ stopping using software that has no advantages.

If you are still not convinced - ask your self about one **real** advantage of using Assetic then continue reading.

### Requirements
There are some requirements that needs to be that need to be met before processing.

#### Install Git
Bower requires Git. Most likely it will be installed on your development environment server. It can be installed from system repository (yum install git on RHEL based distros).

#### Install Node.js
This can be achieved in many ways:
+ installing from your system repository (`yum install nodejs npm` on RHEL based distros)
+ downloading Linux binaries from Node.js website
+ compiling from sources.

#### Install Bower
Bower is a package manager for frontend dependencies (libraries, frameworks, fonts & stuff).

After installing Node.js & npm you can install Bower simply by running the following command: `npm install -g bower` (this will install Bower globally into your system).

#### Install Grunt
Grunt is a Javascript task runner.

Grunt installation requires two steps. You need to install `grunt-cli` package globally and provide grunt as a dependency in your `package.json` file. In this step, just install it globally by running `npm install -g grunt-cli` command.

### Configuration
As all required software has been installed, you can proceed to the next step.

**Important!** Before moving to the next step, you need to add `node_modules` directory to your `.gitignore` file as you don't want to add all node.js modules to your repository.

At this stage, you need to prepare following files:

+ package.json - npm dependencies (most likely Grunt plugins)
+ bower.json - Bower dependencies
+ .bowerrc - Bower runtime configuration
+ .jshintrc - JSHint runtime configuration
+ Gruntfile.js - Grunt configuration.

#### .bowerrc
```
{
  "directory": "web/assets/vendor"
}
```
&nbsp;

#### .jshintrc
```
{
  "bitwise": true,
  "browser": true,
  "curly": true,
  "eqeqeq": true,
  "eqnull": true,
  "esnext": true,
  "immed": true,
  "jquery": true,
  "latedef": true,
  "newcap": true,
  "noarg": true,
  "node": true,
  "strict": true,
  "trailing": true,
  "globals": {
    "define": true
  }
}
``` 

#### bower.json
```
{
  "name": "symfony-frontend",
  "version": "1.0.0",
  "authors": [
    "Andrzej Ośmiałowski <me@osmialowski.co.uk>"
  ],
  "license": "MIT",
  "private": true,
  "ignore": [
    "**/.*",
    "node_modules",
    "test",
    "tests"
  ],
  "dependencies": {
    "jquery": "~1.11.1",
    "bootstrap": "~3.3"
  }
}
```

#### package.json
```
{
  "name": "symfony-frontend",
  "version": "1.0.0",
  "private": true,
  "engines": {
    "node": ">= 0.10.0"
  },
  "devDependencies": {
    "grunt": "~0.4.5",
    "grunt-autoprefixer": "^1.0.1",
    "grunt-contrib-concat": "^0.5.0",
    "grunt-contrib-jshint": "~0.10.0",
    "grunt-contrib-less": "~0.12.0",
    "grunt-contrib-requirejs": "~0.4.4",
    "grunt-contrib-symlink": "^0.3.0",
    "grunt-contrib-uglify": "~0.6.0",
    "grunt-contrib-watch": "~0.6.1"
  }
}
```

As package.json file is ready you can install all Grunt plugins by running `npm install` command. All required modules should in installed into `node_modules` directory.

All bootstrap files have been created and it's time to take care about the `Gruntfile.js`.
```
"use strict";

module.exports = function (grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    appDir: 'web/assets',
    buildDir: 'web/assets-dist'
  });

  grunt.loadNpmTasks('grunt-autoprefixer');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-symlink');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['jshint', 'requirejs', 'less:dev', 'symlink', 'watch']);
  grunt.registerTask('dist', ['jshint', 'requirejs', 'uglify', 'less:dist', 'symlink']);
};
```

At this step there are two path configuration variables, all required Grunt modules are loaded and two main tasks have been created. Two words about those tasks:

+ default - this is default task and should be used on development stage
+ dist - this task should be used to prepaere production ready assets.

Grunt plugins configuration:

#### RequireJS
```
requirejs: {
  main: {
    options: {
      mainConfigFile: '<%= appDir %>/js/main.js',
      appDir: '<%= appDir %>/js',
      baseUrl: '.',
      dir: '<%= buildDir %>/js',
      optimize: "none",
      modules: [
        {
          name: 'main',
          include: ['jquery', 'bootstrap']
        },
        {
          name: 'common',
          exclude: ['main']
        },
        {
          name: 'homepage',
          exclude: ['main']
        }
      ]
    }
  }
},
```

There are three modules configured:

+ main.js - the main RequireJS configuration file. Why including jQuery and Bootstrap as dependencies for this module? Both libraries will be included into main.js file (in fact this file is always used) and are excluded in others modules. Notice: in fact jQuery and Bootstrap are still dependencies for common and homepage modules but those files will not be included into both modules output file.
+ common.js - module that contains code that's being shared on all pages.
+ homepage.js - module for homepage.

##### main.js
```
requirejs.config({
  paths: {
    'jquery': '../vendor/jquery/dist/jquery'
    'bootstrap': '../vendor/bootstrap/dist/js/bootstrap'
  },
  shim: {
    'bootstrap': ['jquery']
  }
});
```


##### common.js 
```
"use strict";

define(['jquery', 'bootstrap'], function ($) {
  // Set up Bootstrap tooltips
  $('[data-toggle="tooltip"]').tooltip();
});
```


##### homepage.js 
```
"use strict";

define(['jquery'], function ($) {
  $('body').css('background', 'red');
});
```


#### JSHint
```
jshint: {
  options: {
    jshintrc: '.jshintrc'
  },
  all: [
    'Gruntfile.js',
    '<%= appDir %>/js/**/*.js'
  ]
}
```


#### Symlink
```
symlink: {
  main: {
    files: [
      {
        expand: true,
        overwrite: false,
        cwd: '<%= appDir %>',
        src: ['img', 'vendor'], // img, fonts, etc.
        dest: '<%= buildDir %>'
      }
    ]
  }
}
```


#### Uglify
```
uglify: {
  options: {
    banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
  },
  dist: {
    files: [{
      src: '<%= buildDir %>/js/**/*.js',
      dest: './',
      expand: true
    }]
  }
}
```


#### Less
```
less: {
  dev: {
    files: {
      '<%= buildDir %>/css/main.css': '<%= appDir %>/less/main.less'
    },
    options: {
      cleancss: false,
      compress: false,
      relativeUrls: true
    }
  },
  dist: {
    files: {
      '<%= buildDir %>/css/main.css': '<%= appDir %>/less/main.less'
    },
    options: {
      cleancss: true,
      compress: true,
      relativeUrls: true
    }
  }
}
```


#### Watch
```
watch: {
  config: {
    files: ['Gruntfile.js'],
    tasks: ['jshint', 'requirejs'],
    options: {
      reload: true,
      spawn: false
    }
  },
  scripts: {
    files: ['<%= appDir %>/js/**/*.js'],
    tasks: ['jshint', 'requirejs'],
    options: {
      spawn: false
    }
  },
  less: {
    files: [
      '<%= appDir %>/less/*.less',
      '<%= appDir %>/less/**/*.less'
    ],
    tasks: ['less:dev'],
    options: {
      spawn: false
    }
  }
}
```


### Symfony configuration
There are two steps required to prepare symfony to use new approach: configure assets path and prepare RequireJS view.

Add the assets variable to your Twig globals in app/config/config.yml file:

```
twig:
  globals:
    assets: "assets-dist"
```

Notice: as you surely noticed, I use the same path for development and production assets (same goes for CSS/JS filenames). Why? Ease of use as you provide only one configuration path, load only one file regardless of environment you are actually working with. It's still flexible as you can customize this though by providing two separate variables in `config_dev.yml` & `config_prod.yml` files and modifying Gruntfile paths.

I store the RequireJS view in `app/Resources/views/requirejs.html.twig` file.

```
<script src="//cdnjs.cloudflare.com/ajax/libs/require.js/2.1.15/require.min.js"></script>
<script>
    requirejs.config({
        baseUrl: '{{ app.request.basePath }}/{{ assets }}/js'
    });

    require(['main'], function () {
        {% if module %}
            require(['common', '{{ module }}']);
        {% else %}
            require(['common']);
        {% endif %}
    });
</script>
```

I think this code is quite self-explaining and does not need more explaination.

I always define requirejs block in base.html.twig file:

```
{% raw %}
{% block requirejs %}
    {{ include('requirejs.html.twig', { module: false }) }}
{% endblock requirejs %}
{% endraw %}
```

To use it in a single view, ex. `AppBundle/Resources/views/Homepage/index.html.twig`:

```
{% raw %}
{% block requirejs %}
    {{ include('requirejs.html.twig', { module: 'homepage' }) }}
{% endblock requirejs %}
{% endraw %}
```

Everything is set up. You can now start writing your top-notch code and forget about Assetic [^3].

I've prepared a [test repository on Github](https://github.com/aosmialowski/symfony-frontend).

---

[^1]: Visit [this](http://stackoverflow.com/questions/25545761/how-to-make-assetic-scan-twig-templates-outside-bundle) Stackoverflow question for more details.
[^2]: Imagine the following situation: you need to change a some code/fix some bugs in your LESS/SASS file. In the classic approach it would require updating the code, pushing the changes to the application repository (as assets are part of Symfony bundle), rebuilding & installing assets. In this approach, you only need to update assets, update your assets repository and update them in the application.
[^3]: Do not remove it thought as it's still required for some bundles (ex: Web Debug Toolbar).

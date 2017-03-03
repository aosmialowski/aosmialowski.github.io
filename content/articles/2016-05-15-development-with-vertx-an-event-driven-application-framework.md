---
title: "Development with Vert.x: an event-driven application framework"
slug: "development-with-vertx-an-event-driven-application-framework"
date: "2016-05-15T14:10:50Z"
type: "article"
categories: ["Development"]
tags: ["java", "jvm", "vertx"]
---

For the last few months I've been intensively working with Java. In last few weeks I work more with Java than PHP or
Javascript. I always wanted to learn Java and I hope it will be my first programming language.

Few weeks ago I've discovered Vert.x - an event-driven polyglot application framework that runs on the Java Virtual
Machine. I've already built two microservices on top of Vert.x. In this post, I'll illustrate why I loved it.

## Philosophy
Vert.x is a polyglot event-driven application framework for Java Virtual Machine. Vert.x can be used with multiple
programming languages such like Java, JavaScript, Groovy, Ruby, & Ceylon by using an idiomatic API provided for every
language that Vert.x support. It's almost worth noting that Vert.x provides an extensive documentation which can
be found on the [official website](http://vertx.io/docs/).

What are the Vert.x features advantages over other frameworks?

  + Vert.x provides an asynchronous idiomatic API for every supported language (See Examples section for more details)
  + Vert.x is fast according to independent benchmarks [^1]
  + Vert.x is lightweight
  + Vert.x is modular
  + Vert.x is non-blocking

## Examples

The best way to see what kind of API Vert.x provides is to see some examples. Here are the ones taken from the [official
website](http://vertx.io):

*Java*
```
import io.vertx.core.AbstractVerticle;

public class Server extends AbstractVerticle {
  public void start() {
    vertx.createHttpServer().requestHandler(req -> {
      req.response()
        .putHeader("content-type", "text/plain")
        .end("Hello from Vert.x!");
    }).listen(8080);
  }
}
```

*Javascript*
```
vertx.createHttpServer()
  .requestHandler(function (req) {
    req.response()
      .putHeader("content-type", "text/plain")
      .end("Hello from Vert.x!");
}).listen(8080);
```

*Groovy*
```
vertx.createHttpServer().requestHandler({ req ->
  req.response()
    .putHeader("content-type", "text/plain")
    .end("Hello from Vert.x!")
}).listen(8080)
```

*Ruby*
```
$vertx.create_http_server().request_handler() { |req|
  req.response()
    .put_header("content-type", "text/plain")
    .end("Hello from Vert.x!")
}.listen(8080)
```

*Ceylon*
```
import io.vertx.ceylon.core { ... }
import io.vertx.ceylon.core.http { ... }

shared class Server() extends Verticle() {
  start() => vertx.createHttpServer()
    .requestHandler(req) =>
      req.response()
        .putHeader("content-type", "text/plain")
        .end("Hello from Vert.x!")
    ).listen(8080);
}
```

As can be seen in the above examples, Vert.x provide the perfect idiomatic API that does not require learning new API
while using different language or migrating from one technology stack to another one. Additional advantage is that you
can intermix languages within one project easily - there's no problem with two separate teams using different languages
working on the same projects. Their code will be easy to understand for the other team members as their use the same API.

Some of the Vert.x features and parts of its architecture will be covered in the next parts of this article.

## Verticles
Vert.x documentation describes Verticles with the following statement:

> Vert.x comes with a simple, scalable, actor-like deployment and concurrency model out of the box that you can use to
> save you writing your own.

Verticle can be considered as an unit-of-work-like component inside Vert.x instance. Verticles are started immediately
when they are deployed and keep running all the time until the Vert.x instance is stopped. A common application may
consist of one Verticle or several Verticles. They communicate with each other through Event Bus.

Each Verticle is isolated and has a separate class loader. A single Verticle is always executed by a single thread
concurrently.

### Writing Verticles

*Example Verticle*
```
public class CustomVerticle extends AbstractVerticle {

  @Override
  public void start() {
    // Called when verticle is deployed
  }

  @Override
  public void stop() {
    // Called when verticle is undeployed
  }
}
```

Each Verticle class needs to extends `AbstractVerticle` class. Most probably a `start` method will be overridden, while
overriding `stop` method is optional. When the Verticle is deployed by Vert.x instance, the `start` method will be
called. When the `start` method completes the Verticle will be considered started. The same goes for the `stop` method.
It will be called by Vert.x when Verticle is undeployed. When the `stop` method completes the Verticle will be considered
stopped.

### Asynchronous Verticles

Sometimes your Verticle needs to perform a long-time action, for example another Verticle needs to be deployed. To achieve
that an asynchronous start method can be used. In this concept a `start` (or `stop`) method takes a `Future` as a parameter.
The Verticle will not be considered started unless a `complete` or `fail` methods will be called on the `Future` object.

*Asynchronous Verticle example*
```
public class MyVerticle extends AbstractVerticle {

  public void start(Future<Void> startFuture) {
    vertx.deployVerticle("com.foo.OtherVerticle", res -> {
      if (res.succeeded()) {
        startFuture.complete();
      } else {
        startFuture.fail(res.cause());
      }
    });
  }
}
```

## Event Bus

The Event Bus is the most important component of Vert.x framework - it allows application components to communicate with
each other. Event Bus can be used by components written in different languages. Every instance contain only one Event Bus
instance. Event Bus can be also accessed by application parts that are located in different Vert.x instances.

### Event Bus messaging

The Vert.x Event Bus supports the following messaging types:

  + publish/subscribe - messages are published to an address. All handlers that are registered at specific address will
  receive the message.
  + point to point - message are sent to an address. Message will be routed by Vert.x to one of the registered handlers
  at specific address.
  + request-response - same as point to point type, with one exception. An optional reply handler can be defined. If
  there's a reply handler defined, the reply will be sent by the message recipient. The original sender of the message
  can still reply - an infinite loop is achievable.

The usage of Event Bus requires only message handlers management (registering & unregistering) and about sending or
publishing messages. Vert.x documentation contains great examples of real world usages of Event Bus.

## HTTP server & client

Vert.x supports creating HTTP servers & clients supporting HTTP/1.0, HTTP/1.1 & HTTP/2.0 protocols out of the box. They
can be used to create REST APIs & API clients in no time.

*Creating HTTP server with default options*
```
HttpServer server = vertx.createHttpServer();
```

*Creating HTTP client with default options*
```
HttpClient client = vertx.createHttpClient();
```

As can be seen in the above examples, creating HTTP server & client requires almost no code. Of course, all options can
be overridden.

## Summary

As you can see, Vert.x is a really powerful tool. As a general purpose framework it can be used to develop any kind of
application: HTTP/REST microservices, network services, high volume event processing.

In the next blog post, the development of sample Vert.x application will be covered.

---

[^1]: Full benchmark available at [techempower.com](https://www.techempower.com/benchmarks/#section=data-r8&hw=i7&test=plaintext)
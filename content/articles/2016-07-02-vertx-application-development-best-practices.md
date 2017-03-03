---
title: "Vert.x application development best practices"
date: "2016-07-02T15:40:22Z"
type: "article"
categories: ["Develpment"]
tags: ["java", "jvm", "vertx"]
---

As can be seen in the article history I recently fall in love with Vert.x - an event-driven framework for JVM. So far
there are two Vert.x related posts on this blog:

  + [Development with Vert.x: an event-driven application framework](/development-with-vert.x-an-event-driven-application-framework/)
  + [Developing a simple application with Vert.x](/developing-example-vert.x-application/).

This post will be a summary of Vert.x best practices.

## Don't block the event loop

This is the primary and the most important rule for working with asynchronous frameworks. All Vert.x APIs are non blocking
and will not block the event loop. But the issue will occur if the Event Bus will be blocked in the code. As blocking
operations cannot be called directly the blocking operations need to be called within `executeBlocking` method that specifies
the blocking code that needs to be executed and the result handler that will be called asynchronously when the blocking
operation has been completed. Vert.x documentation provides a good example:

```
vertx.executeBlocking(future -> {
  // Call some blocking API that takes a significant amount of time to return
  String result = someAPI.blockingMethod("hello");
  future.complete(result);
}, res -> {
  System.out.println("The result is: " + res.result());
});
```

Another option is to use Worker verticles that is not executed using an event loop, but using thread from worker thread
pool. Worker verticles are designed to run blocking code and are never executed by more than one thread.

*Worker verticle example*
```
DeploymentOptions options = new DeploymentOptions().setWorker(true);
vertx.deployVerticle("com.mycompany.MyOrderProcessorVerticle", options);
```

## Use Vert.x documentation

It might sound trivial, but Vert.x official documentation is one of the best docs I've ever seen. There're official
repositories with examples on Github which may give you a clue how to solve an issue you face or might be a good place to
start if you look for an architecture design example.

## Keep application responsive

Test your application as often as possible. Perform stress tests to check its responsiveness. If your thread is blocked
for a long time, you need to check if you do not execute any blocking code on non-worker Verticle (or without
`executeBlocking` method).

## Multiple small verticles

Use as many verticles as you need. Don't break the *single responsibility principle* with using single verticle that would
be responsible for all business logic within your application. Keep verticles as small as possible.

## Summary

Those few advices will help you developing fast, scalable and lightweight applications based on Vert.x. You just need to
remember about the main rule "do not block the event loop". Having any other ideas? Share them in comments or fork this
blog post and contribute!
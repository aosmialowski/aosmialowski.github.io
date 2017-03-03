---
title: "Developing example Vert.x application"
date: "2016-06-28T11:12:48Z"
type: "article"
categories: ["Development"]
tags: ["java", "jvm", "vertx"]
---

In [one](/development-with-vertx-an-event-driven-application-framework/) of the previous posts Vert.x - an event-driven
application framework has been introduced. The basic features has been described as were as framework advantages and
architecture. In this post, a simple Vert.x application development process will be described.

## Prerequisites
There are only two requirements: Java 8 (Vert.x requires Java 8) and a build tool of your choice. In this article Apache Maven will be used. You
may also use Maven archetype to generate the project structure with all dependencies.

A standard Maven directory structure will be required:
```
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   └── resources
│   └── test
│       └── java
```

## Dependencies

As `vertx-core` is the first dependency, the `pom.xml` file should look like the following:
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>net.osmialowski</groupId>
    <artifactId>vertx-example</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <java.version>1.8</java.version>
        <vertx.version>3.2.1</vertx.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>io.vertx</groupId>
            <artifactId>vertx-core</artifactId>
            <version>${vertx.version}</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.3</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

To test application, two more dependencies are required `junit` and `vertx-unit`.
```
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>${junit.version}</version>
    <scope>test</scope>
</dependency>

<dependency>
    <groupId>io.vertx</groupId>
    <artifactId>vertx-unit</artifactId>
    <version>${vertx.version}</version>
    <scope>test</scope>
</dependency>
```

## Development

When all dependencies are configured correctly, now it's time to create a first Verticle in our Vert.x application. What
a Verticle is? A Vert.x introduction can be found in [one of previous posts](/development-with-vertx-an-event-driven-application-framework/).

*src/main/java/net/osmialowski/vertx/example/MyVerticle.java*
```
package net.osmialowski.vertx.example;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.Future;

public class MyVerticle extends AbstractVerticle {

    @Override
    public void start(Future<Void> future) {
        vertx.createHttpServer()
                .requestHandler(request -> {
                    request.response().end("<h1>Hello World</h1><h2>Sample Vert.x Application</h2>");
                })
                .listen(8800, result -> {
                    if (result.succeeded()) {
                        future.complete();
                    } else {
                        future.fail(result.cause());
                    }
                });
    }
}
```

As can be seen, the Verticle code is quite simple and easy to understand. However an explanation what's going on under
the hood is always good:

  + every Verticle class needs to extend `AbstractVerticle` class
  + `start` method is being overridden
  + overriding `stop` method is completely optional
  + `start` method takes a `Future` object as an argument
  + `start` method is called by Vert.x when the Verticle is deployed
  + as Vert.x is asynchronous & non-blocking framework `Future` object is important to notify the completion or the
  failure of the `start` method.

The code can be now compiled with `mvn clean compile` - the process should succed without any error or warning.

## Testing

As can be noticed above, we added `junit` and `vertx-unit` as our application dependencies. They will be now used to
write tests for our application.

*src/test/java/net/osmialowski/vertx/example/MyVerticleTest.java*
```
package net.osmialowski.vertx.example;

import io.vertx.core.Vertx;
import io.vertx.ext.unit.Async;
import io.vertx.ext.unit.TestContext;
import io.vertx.ext.unit.junit.VertxUnitRunner;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(VertxUnitRunner.class)
public class MyVerticleTest {

    private Vertx vertx;

    @Before
    public void setUp(TestContext context) {
        vertx = Vertx.vertx();
        vertx.deployVerticle(MyVerticle.class.getName(), context.asyncAssertSuccess());
    }

    @After
    public void tearDown(TestContext context) {
        vertx.close(context.asyncAssertSuccess());
    }

    @Test
    public void testApplication(TestContext context) {
        final Async async = context.async();

        vertx.createHttpClient().getNow(8800, "localhost", "/", response -> {
            response.handler(body -> {
                context.assertTrue(body.toString().contains("Vert.x"));
                async.complete();
            });
        });
    }
}
```

The above JUnit test class for our application is quite simple. The usage of `vertx-unit` custom runner makes testing
asynchronous requests easy. Some explanation:

  + in `setUp` method our Verticle is deployed
  + in `tearDown` method Vert.x instance is terminated
  + in the test method an HTTP client is created and connects via HTTP protocol with our server created in the Verticle
  + the test asserts that content body contains "Vert.x" word.

The test can be executed using Maven: `mvn clean test`.

## Packaging

A custom Verticle has been created as well as the test class for the application. Now a jar file will be required to run
the application on the server. To achieve this `maven-shade-plugin` Maven plugin will be used to create a `fat jar`
that contains our application with all required dependencies. The configuration for the plugin should look like the
following:

```
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>2.4.2</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <manifestEntries>
                            <Main-Class>io.vertx.core.Launcher</Main-Class>
                            <Main-Verticle>net.osmialowski.vertx.example.MyVerticle.java</Main-Verticle>
                        </manifestEntries>
                    </transformer>
                </transformers>
                <artifactSet />
                <outputFile>${project.build.directory}/${project.artifactId}-${project.version}-prod.jar</outputFile>
            </configuration>
        </execution>
    </executions>
</plugin>
```

`Launcher` class will create Vert.x instance and will deploy our Verticle (main Verticle is defined in the `Main-Verticle`
property). **Important:** note that class `io.vertx.core.Starter` has been replaced by `io.vertx.core.Launcher` class in
Vert.x 3.1.0. The application can be build with `mvn clean package` command.

## Running

To run the application simply execute the `fat jar` generated with `mvn clean package` command:

```
java -jar target/vertx-example-1.0-SNAPSHOT-prod.jar
```

## Summary

Voila! A simple Vert.x application has just been built. All source code is available in [Github repository](https://github.com/aosmialowski/vertx-example).
Feel free to contribute or propose the enhancements of the Vert.x tutorials.
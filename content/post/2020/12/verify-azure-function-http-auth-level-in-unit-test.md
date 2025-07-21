---
title: "Test Your Azure Function Http Trigger Authorization Levels" # Title of the blog post.
date: 2020-12-17T09:24:03Z # Date of post creation.
description: "How to use a unit test to verify your Azure Functions Http Trigger authorization levels." # Description used for search engine.
featured: true # Sets if post is a featured post, making appear on the home page side bar.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
# menu: main
codeMaxLines: 100 # Override global value for how many lines within a code block before auto-collapsing.
categories:
  - Coding
tags:
  - Unit test
  - Azure
  - Azure Functions
---

If you are using HTTP trigger bindings and are relying on keys to secure them using `AuthorizationLevel.Function`,
you might want a way verify that you haven't accidentally left one of them exposed
as `AuthorizationLevel.Anonymous`.

With a bit of reflection you can accomplish this in a unit test (I'm using the excellent [xUnit](https://xunit.net/) 
and [FluentAssertions](https://fluentassertions.com) here):

``` csharp
[Fact]
public void AllHttpTriggerFunctions_MustHaveFunctionSecurity()
{
    // Get the assembly containing the Azure Functions
    var types = typeof(Startup).Assembly.GetTypes();

    // Find all the HttpTriggerAttributes associated to any method in any of the types
    // in the assembly
    var httpTriggerAttributes = types
      .SelectMany(t => t
        .GetMethods()
          .Select(m => m.GetParameters()
            .Select(p => p.GetCustomAttribute<HttpTriggerAttribute>()).FirstOrDefault()))
      .Where(p => p != null)
      .ToList();

    httpTriggerAttributes.Should().NotBeEmpty();

    foreach (var httpTrigger in httpTriggerAttributes)
    {
        httpTrigger.AuthLevel.Should().Be(AuthorizationLevel.Function);
    }
}
```

That's it. Now it's even harder to make a mistake, which is a good thing.
---
title: "DynaCache- just like page output caching, but for classes"
date: "2012-01-15T00:00:00.0000000"
author: "Mike Goatly"
---
Anyone who has done any serious work with any ASP\.NET based
framework will know that page output caching is a great feature\.
For those not familiar with it\, the basic premise is that it makes
sure that the generation of content is done only once for a set of
parameters\, and that all subsequent requests with the same
parameters are served up from the cache for a specified period of
time\.

Wouldn't it be nice if you could do a similar thing for methods
on classes\, just by applying an attribute like this?

``` csharp

[CacheableMethod(30)]
public virtual string GetData(int id)
```
Thanks to a little library called [DynaCache](http://dynacache.codeplex.com/)\, you can\!

## How does it work?

Say you have a class called TestClass:

![image](/images/post/2012/01/initialhierarchy.png)

The LoadData method is marked as virtual\, and has an attribute
called CacheableMethod applied to it\, indicating the number of
seconds the results should be cached for\.

The CachableMethod attribute is the first interaction with the
DynaCache framework \- the second is with a class called
Cacheable:

![image](/images/post/2012/01/Windows-Live-Writer_80eb766f89d3_AD04_image_0f38d0f3-6b54-41f4-9aea-7d2d2bddbac3.png)

Calling *Cacheable\.CreateType<TestClass>\(\)* at
runtime creates a new class called *CacheableTestClass*\,
deriving from TestClass and overriding any methods with the
CachableMethod attribute\, resulting in a class hierarchy like
this:

![image](/images/post/2012/01/fullhierarchy.png)

This new class is created using Reflection\.Emit and only exists
in memory\, so you can't use a reflector\-like program to see what's
generated\, but if you could it would look something like this:

``` csharp

public class CacheableTestClass : TestClass
{
    private IDynaCacheService cacheService;
    
    public TestClass(IDynaCacheService cacheService)
    {
        this.cacheService = cacheService;
    }

    public override string LoadData(int id)
    {
        string cacheKey = String.Format(CultureInfo.InvariantCulture, "TestClass_LoadData(Int32).{0}", id);
        object result;
        if (!this.cacheService.TryGetCachedObject(cacheKey, out result))
        {
            result = base.LoadData(id);
            this.cacheService.SetCachedObject(cacheKey, result, 200);
        }
        
        return (string)result;
    }
}
```
Notice the IDynaCacheService parameter in the constructor?
That's the third piece of the DynaCache framework \- an instance of
a class capable of interacting with whatever backing cache is being
used\. Out of the box DynaCache includes a concrete implementation
of this called MemoryCacheService \- it's just a wrapper around a
\.NET 4 MemoryCache instance\. There's no reason why you shouldn't
create your own though\, e\.g\. for the ASP\.NET or Windows Azure
cache\.

## Making it simple with dependency injection

What this all means is that at runtime you need to be using
CacheableTestClass rather than TestClass\, otherwise all the
generated caching code will never be used\. Although it's possible
to construct and use these types yourself\, the simplest and best
way to do that is to use a dependency injection framework\, such as
Ninject\, StructureMap\, etc\.

For the sake of illustration\, I'm going to use Ninject\. The
original configuration would have simply mapped ITestClass to
TestClass\, like this:

``` csharp

kernel.Bind<ITestClass>().To<TestClass>();
```
Using DynaCache is only marginally more complicated\, you just
configure your kernel like this:

``` csharp

kernel.Bind<IDynaCacheService>().To<MemoryCacheService>();
kernel.Bind<ITestClass>().To(Cacheable.CreateType<TestClass>());
```
The first line configures the cache service to pass to instances
of CacheableTestClass*\,* whilst the second binds ITestClass
to the cacheable version of TestClass\.

That's all there is to it\! Now every time an instance of
ITestClass is required\, Ninject will construct and return an
instance of CacheableTestClass \- the rest of your code that
consumes ITestClass will automatically make use of the dynamically
constructed caching code\.

## Where to get DynaCache

You can get it from the [CodePlex project site](http://dynacache.codeplex.com/)\, or you can install it
into your project using the Nuget command:

```

Install-Package DynaCache
```
## Summary

Hopefully all the detail hasn't put you off \- this whole article
essentially boils down to just these three steps:

1. Make the methods overridable and apply the CacheableMethod
attribute to them\.
1. Configure your DI framework to return an instance of
IDynaCacheService\, either MemoryCacheService or one you have
implemented yourself\.
1. Configure your DI framework to return the result of
*Cacheable\.CreateType* for your type\.

I'd be really interested in feedback for DynaCache \- let me know
your thoughts in comments below\, or on the project discussion
board\.


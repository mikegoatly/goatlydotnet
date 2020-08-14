---
title: "Advanced querying with LIFTI"
date: "2010-12-24T00:00:00.0000000"
author: "Mike Goatly"
---

> As always\, you can find the LIFTI project at its CodePlex home:
> [http://lifti\.codeplex\.com](http://lifti.codeplex.com)\.
> 
> 

Until now\, the way in which you can query against LIFTI has been
pretty basic\. If you searched for "apple orange"\, you would only
get items back that had words starting with **both**
apple and orange in their associated text\.

For simple scenarios this is fine\, but what if you wanted to
search for apple **or** orange? What if you actually
wanted both apple and orange\, but they had to be near to each
other? Well I have a extra special treat for you this
Christmas\.

## Introducing better\, more expressive queries

I've just checked in changes to the LIFTI library that will
allow you to perform these sort of queries:

|Query|Meaning|
|-|-|
|Deployment|Items that contain the word *deployment* exactly\*\.|
|doc\*|Items that contain words that start with *doc*\.|
|Deployment & document|Items that contain both *deployment* and *document*\.|
|Deployment | document|Items that contain either *deployment* or *document*\.|
|Deployment ~ doc\*|Items containing the word *deployment* near a word that starts with *doc*\.|
|Deployment ~> document|Items containing the word *deployment* that are followed closely by *document*\.|
|Deployment >> document|Items containing the word *deployment* followed by *document* anywhere after it\.|
|"the bug catcher"|Items that have the words *the bug catcher* one after another\.|
|"notr\* dam\*"|Items that have a word that start with *notr* then a word that starts with *dam*\, one after another\.|
|Deploy\* ~> \(document | server\)|Items that have words starting with *deploy*\, closely followed by either *document* or *server*\.|

\* "Exactly" is not quite accurate \- if you're using the [stemming word splitter](/2010/12/7/lifti-and-porter-stemming.aspx)\, then it will also match
other derivatives of the word\.

## The more things change\, the more they stay the same

Don't panic if you only want the simple search behaviour\! LIFTI
was created to be really simple to use\, with a really simple API\,
and I haven't forgotten that\. With that in mind\, simple searching
is still the default behaviour\.

In order to use to this shiny new query engine\, you need to set
the new **QueryParser** property to an instance of
**LiftiQueryParser** when you create a new
FullTextIndexer\, like this:

``` csharp

var index = new FullTextIndexer<customer>(c => c.Biography)
{    
    QueryParser = new LiftiQueryParser()
};
```
*\(For those interested\, the default query parser class is
called **SimpleQueryParser**\, unsurprisingly\)*

## Words are boring\, show me a picture\!

In the Samples folder of the LIFTI solution\, you'll now find a
new sample called **StackOverflowSample** \- when you
run it\, you'll see something like this:

[![image_thumb[6]](/images/post/Windows-Live-Writer_85b645c929c4_EC66_image_thumb%5B6%5D_thumb.png)](/images/post/Windows-Live-Writer_85b645c929c4_EC66_image_thumb%5B6%5D_2.png)

You can type in the query at the top\, and once you press search\,
3 things will happen:

- The titles of any matching questions are shown in the left
panel of the search results \- clicking on one of these will show
the question body on the right\. Note that only the text in the body
of the article is indexed\.
- A textual version of the query will be shown below your search
\(this is just the result of a ToString on the parsed query\)
- The time it took to parse and then execute the search is shown
under the search results\.

This sample application is also included in the latest binaries
download \(v0\.3\)\.

## What about the documentation?

Ok\, so LIFTI is getting a little more complex and I'm going to
have to start finding some time to write the documentation on
CodePlex\. There's nothing substantial there at the moment\, but I'm
hoping to find some time to get something written over the holiday
\- bear with me\!

I hope that someone out there is finding this useful\, or at
least interesting \- I am\!

Happy Christmas\!


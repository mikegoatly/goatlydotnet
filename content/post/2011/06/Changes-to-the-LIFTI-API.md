---
title: "Changes to the LIFTI API"
date: "2011-06-08T00:00:00.0000000"
author: "Mike Goatly"
---

> This post relates to the breaking changes between version 0\.4
> and 0\.5 of LIFTI\. LIFTI is a full\-text indexing library for \.NET \-
> find out more on its [CodePlex site](http://lifti.codeplex.com/)\.
> 
> 

The latest release of LIFTI has several breaking changes that
**will** affect you\, so I wanted to take some time to
explain not only what they are\, but why I made them\. I'll start
with the what\, then move onto the why\.

## No more constructor delegates

Previously when you wanted to construct a full text index\,
updatable or otherwise\, you would have had to provide a delegate
that was capable of taking the type of item in the index and
returning the text it should be indexed against\, like this:

``` csharp

var index = new FullTextIndex<Customer>(c => c.Name);
```
This is no longer the case \- constructing an index is now as
simple as it can be:

``` csharp

var index = new FullTextIndex<Customer>();
```
If you have been using LIFTI you'll probably be aware that the
reason the constructor used to take a delegate was to provide some
of the Index methods with the text an item should be index against;
this leads me nicely onto the next change\.

## A rationalised set of Index methods

There used to be 5 Index methods \- these have been reduced to 4\,
which can be broken into two categories\, *indexing keys* and
*indexing arbitrary classes*\.

### Indexing "keys" rather than "items"

It's often useful \(and when it comes to using a persisted index\,
just plain sensible\) to store just a key to an item in the index\.
That is to say\, rather than storing a "Movie" class in the index\,
just storing the customer ids\, e\.g\. an integer\. There are two Index
methods that support this:

``` csharp

// Explicitly pass the key and text values
index.Index(movie.MovieId, movie.Description);
index.Index(movieId, description);

// Or you can index an enumerable of keys like this
var ids = new[] { 23, 44, 192 };
index.Index(ids, i => LoadDescriptionForMovie(i));
```
### Indexing arbitrary classes in the index

There are two Index methods on the IFullTextIndex interface that
you can use to index instances of Movie directly\, should you so
wish:

``` csharp

// Pass the movie instance and use delegates to extract the 
// relevant information
var movie = new Movie { MovieId = 1, Description = "Best movie ever!" };
index.Index(movie, m => m.MovieId, m => m.Description);

// The equivalent "index many":
var movies = new[] 
{
    new Movie { MovieId = 1, Description = "Best movie ever!" },
    new Movie { MovieId = 2, Description = "Worst movie ever!" }
};
index.Index(movies, m => m.MovieId, m => m.Description);
```
## No more Reindex methods

I'm hoping you'll not miss them though\. Instead\, when you're
using an updatable index\, either UpdatableFullTextIndex or
PersistedFullTextIndex\, calls to any of the Index methods will
automatically remove the item from the index prior to indexing\, if
it's already there\.

## Serialization namespace is gone

That's right\, gone\, along with all the serialization classes in
it\. If you were using it\, I really am sorry\, but there were good
reasons to do so\, and I think there are much better alternatives
now\.

## Ok\, so why?

First up\, I'll deal with the changes to the constructor and the
Index methods\, because they are both closely related\.

### Constructors and Indexing

While I was writing the original serialization code \(even before
the persisted full text index work\) it became apparent that under
most circumstances it was going to be best to store a simple value
type \(e\.g\. int\) in the index\, rather than an arbitrary class \(e\.g\.
Customer\)\. The reason for this was twofold:

1. Primitive types are just a lot easier to serialize \- most of
the time LIFTI can handle primitive types without any
configuration\.
1. If you're serializing the full text index somewhere\, the
chances are the classes are going to be persisted somewhere else\,
probably a database of some sort\. Persisting the classes in the
serialized index is a bad case of data duplication and things will
definitely get out of sync sooner or later\.

Although it's possible\, storing a simple id in the index doesn't
lend itself naturally to using a delegate to read out the related
text\. It would usually mean having to call out to another method\,
like this:

``` csharp

var index = new FullTextIndex<int>(i => GetTextForCustomerId(i));
```
Ok\, you could write it like this\, but it feels even more
odd:

``` csharp

var index = new FullTextIndex<int>(GetTextForCustomerId);
```
Indeed\, sometimes it may not even be possible to write a
delegate ahead of time to return the text for an id \- you might
just have access to an id and a piece of text at the time it comes
to perform the indexing\.

Taking all this into account\, hopefully it's fairly clear why I
decided to remove the delegate from the constructor and\, because
some of the Index methods relied on there being a pre\-defined way
of getting hold of the text for a key value\, why it was necessary
to rationalise the Index methods\.

But couldn't I just have added a separate overload for the
constructor\, or allow the delegate to be null? Well\, yes\, naturally
I could\, and I tried it for a while\, but I felt that it made the
API a bit more confusing\. Some of the Index methods had to throw
exceptions at runtime if no delegate was provided upon construction
\- not very nice at all\. At least this way you know where you stand
\- each and every Index method must be given enough information to
identify a key value and its associated text\.

### Getting rid of the Reindex methods

I did this primarily because I was a little uncomfortable just
throwing an exception up if an Index method was called and the key
already existed in the index \- in some circumstances it felt like
this was the wrong behaviour\. Realistically all this does is save
the use of API needing to check to see if item exists and adjust
their behaviour depending on the result\.

### Getting rid of old Serialization classes

The decision to do this influenced by a couple of factors\. The
first was the fact that I had just implemented the persisted index\,
which covers exactly what the old serialization code did with the
added benefit that you don't need to remember to serialize the
index when your application exits and you don't have to manually
deserialize it when the application starts\. The deserialization
point is particularly interesting; the old serialization process
required that the entire index was loaded into memory before it
could be used \- the persisted index lazy loads parts of the index
as it is accessed\, which for large indexes can make it available
for use in a much shorter space of time\. I'll cover more on this
lazy loading in a later post\.

Another factor was that in order to support the old
serialization process I had to expose elements of the full text
index class that I wasn't really happy doing\. For example in 0\.4
the RootNode property of the IFullTextIndex interface had a setter
\- allowing the root node to be changed this way was a bit scary and
had big implications for the persisted index implementation\. There
were probably other ways around this\, but this combined with the
first point made the decision fairly easy\.

## Wrap up

This is the first time I have had to make significant breaking
changes to the API \- I'm not going to promise it's the last\, but I
think it is approaching something that resembles a stable
state\.

Some of these changes may be controversial\, and I'm sure that
other people will have differing opinions on how it should have
been done\. I'd be really interested to hear if the changes have
been significantly problematic for you \- either leave me a comment
here\, or start a thread on the [discussions board](http://lifti.codeplex.com/discussions)\. I want to hear all feedback\,
positive or negative\!

